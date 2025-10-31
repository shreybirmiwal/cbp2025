#!/bin/bash

# Output file for results
OUTPUT_FILE="bimodal_results.csv"
TRACE_FILE="media/media_0_trace.gz"

# Write CSV header
echo "TABLE_SIZE,NumBr,MispBr,mr,mpki" > "$OUTPUT_FILE"

# Array of TABLE_SIZE values to test
TABLE_SIZES=(1 100 1000 10000 100000 1000000)

# Backup the original file
cp my-predictors/bimodalPredictor.h my-predictors/bimodalPredictor.h.bak

for size in "${TABLE_SIZES[@]}"; do
    echo -e "\n=== Testing TABLE_SIZE = $size ==="
    
    # Update the TABLE_SIZE in the header file
    sed -i '' "s/static const int TABLE_SIZE = [0-9]\+/static const int TABLE_SIZE = $size/" my-predictors/bimodalPredictor.h
    
    # Clean and build
    echo "Building with TABLE_SIZE = $size..."
    make clean
    if ! make -j$(nproc); then
        echo "Build failed for TABLE_SIZE = $size"
        continue
    fi
    
    # Run the test and capture the last line of output
    echo "Running simulation with $TRACE_FILE..."
    if [ -f "./cbp" ]; then
        # Run and capture the last line of output
        result=$(./cbp "$TRACE_FILE" | tail -n 1)
        
        # Print the full result for debugging
        echo "Result: $result"
        
        # Try to extract the relevant columns (adjust these based on actual output format)
        if [[ $result =~ ([0-9]+)[[:space:]]+([0-9]+)[[:space:]]+([0-9.]+)%[[:space:]]+([0-9.]+) ]]; then
            num_br="${BASH_REMATCH[1]}"
            misp_br="${BASH_REMATCH[2]}"
            mr="${BASH_REMATCH[3]}"
            mpki="${BASH_REMATCH[4]}"
            
            # Append to results file
            echo "$size,$num_br,$misp_br,$mr,$mpki" | tee -a "$OUTPUT_FILE"
        else
            # If the format doesn't match, just save the raw output
            echo "$size,$result" | tee -a "$OUTPUT_FILE"
        fi
    else
        echo "Error: ./cbp not found after build"
    fi
    
    echo "Completed test for TABLE_SIZE = $size"
done

# Restore the original file
mv my-predictors/bimodalPredictor.h.bak my-predictors/bimodalPredictor.h

echo -e "\n=== Testing complete ==="
echo "Results saved to $OUTPUT_FILE"

# Display the results in a nice table
echo -e "\n=== Results Summary ==="
column -t -s, "$OUTPUT_FILE" 2>/dev/null || cat "$OUTPUT_FILE"
