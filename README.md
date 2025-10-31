# cbp2025
Championship Branch Prediction 2025

## Build
The simulator expects a branch predictor to be implemented in the files my_cond_branch_predictor.{h/cc}. The predictor gets statically instantiated. For reference, check sample predictor file: [my_cond_branch_predictor.h](./my_cond_branch_predictor.h)

To build the simulator:

`make clean && make`

## Branch Predictor Interface

The simulator interacts with the branch predictor via the following interfaces:
* beginCondDirPredictor - Intended for any predictor initialization steps.
* notify_instr_fetch - Called when an instruction is fetched.
* get_cond_dir_prediction - invoke the predictor to get the prediction of the relevant branch. This is called only for conditional branches.
* spec_update - Intended to help update the predictor's history (GHR/LHIST ..etc.) This is called for all branches right after a prediction is made.
* notify_instr_decode - Called when an instruction is decoded.
* notify_agen_complete - Called when agen of a load/store instruction completes.
* notify_instr_execute_resolve - Called when any instruction is executed.
* notify_instr_commit - Called when any instruction is committed.
* endCondDirPredictor - Called at the end of simulation to allow contestants to dump any additional state.

These interfaces get exercised as the instruction flows through the cpu pipeline, and they provide the contestants with the relevant state available at that pipeline stage. The interfaces are defined in [cbp.h](./cbp.h) and must remain unchanged. The structures exposed via the interfaces are defined in [sim_common_structs.h](lib/sim_common_structs.h). This includes InstClass, DecodeInfo, ExecuteInfo ..etc.

See [cbp.h](./cbp.h) and [cond_branch_predictor_interface.cc](./cond_branch_predictor_interface.cc) for more details.

### Contestant Developed Predictor

The simulator comes with CBP2016 winner([64KB Tage-SC-L](./cbp2016_tage_sc_l.h)) as the conditional branch predictor. Contestants may retain the Tage-SC-L and add upto 128KB of additional prediction components, or discard it and use the entire 192KB for their own components. Contestants are also allowed to update tage-sc-l implementation.
Contestants are free to update the implementation within [cond_branch_predictor_interface.cc](./cond_branch_predictor_interface.cc) as long as they keep the branch predictor interfaces (listed above) untouched. E.g., they can modify the file to combine the predictions from the cbp2016 tage-sc-l and their own developed predictor.

In a processor, it is typical to have a structure that records prediction-time information that can be used later to update the predictor once the branch resolves. In the provided Tage-SC-L implementation, the predictor checkpoints history in an STL map(pred_time_histories) indexed by instruction id to serve this purpose. At update time, the same information is retrieved to update the predictor.
For the predictors developed by the contestants, they are free to use a similar approach. The amount of state needed to checkpoint histories will NOT be counted towards the predictor budget. For any questions, contestants are encouraged to email the CBP2025 Organizing Committee.

## Examples
See Simulator options:

`./cbp`

Running the simulator on `trace.gz`:

`./cbp trace.gz`

Running with periodic misprediction stats at every 1M instr(`-E <n>`)

`./cbp -E 1000000 trace.gz`

## Notes

Run `make clean && make` to ensure your changes are taken into account.

Sample traces are provided : [sample_traces](./sample_traces)

Script to run all traces and dump a csv is also provided : [trace_exec_training_list](scripts/trace_exec_training_list.py)

Reference results from the training set are included here : [reference_results](reference_results_training_set.csv)

To run the script, update the trace_folder and results dir inside the script and run:

`python trace_exec_training_list.py  --trace_dir sample_traces/ --results_dir  sample_results`

The script executes all the traces inside the trace directory and creates a directory structure with the logs similar to thr trace-directory with all the logs.

The script also parses all the logs to dump a csv with relevant stats.

## Getting Traces

[Link to Training Set- 105 traces](https://drive.google.com/drive/folders/10CL13RGDW3zn-Dx7L0ineRvl7EpRsZDW)

Contestants can also use 'gdown' do download the traces:

`pip install gdown`

`gdown --folder //drive.google.com/drive/folders/10CL13RGDW3zn-Dx7L0ineRvl7EpRsZDW`

To untar the traces:

`tar -xvf foo.tar.xz`

### Data Dependent conditional branch characterization

[Data Dependent Conditional Branch Characterization](https://ericrotenberg.wordpress.ncsu.edu/files/2025/02/CBP2025-data-dependent-branch-profiles.pdf) for the training traces is available. This may be leveraged to pursue interesting directions for the branch predictor design.

## Sample Output Per Run

```
WINDOW_SIZE = 1024
FETCH_WIDTH = 16
FETCH_NUM_BRANCH = 16
FETCH_STOP_AT_INDIRECT = 1
FETCH_STOP_AT_TAKEN = 1
FETCH_MODEL_ICACHE = 1
PERFECT_BRANCH_PRED = 0
PERFECT_INDIRECT_PRED = 1
PIPELINE_FILL_LATENCY = 10
NUM_LDST_LANES = 8
NUM_ALU_LANES = 16
MEMORY HIERARCHY CONFIGURATION---------------------
STRIDE Prefetcher = 1
PERFECT_CACHE = 0
WRITE_ALLOCATE = 1
Within-pipeline factors:
  AGEN latency = 1 cycle
  Store Queue (SQ): SQ size = window size, oracle memory disambiguation, store-load forwarding = 1 cycle after store's or load's agen.
  * Note: A store searches the L1$ at commit. The store is released
  * from the SQ and window, whether it hits or misses. Store misses
  * are buffered until the block is allocated and the store is
  * performed in the L1$. While buffered, conflicting loads get
  * the store's data as they would from the SQ.
I$: 128 KB, 8-way set-assoc., 64B block size
L1$: 128 KB, 8-way set-assoc., 64B block size, 3-cycle search latency
L2$: 4 MB, 8-way set-assoc., 64B block size, 12-cycle search latency
L3$: 32 MB, 16-way set-assoc., 128B block size, 50-cycle search latency
Main Memory: 150-cycle fixed search time
---------------------------STORE QUEUE MEASUREMENTS (Full Simulation i.e. Counts Not Reset When Warmup Ends)---------------------------
Number of loads: 417260
Number of loads that miss in SQ: 239412 (57.38%)
Number of PFs issued to the memory system 5411
---------------------------------------------------------------------------------------------------------------------------------------
------------------------MEMORY HIERARCHY MEASUREMENTS (Full Simulation i.e. Counts Not Reset When Warmup Ends)-------------------------
I$:
  accesses   = 1313295
  misses     = 44
  miss ratio = 0.00%
  pf accesses   = 0
  pf misses     = 0
  pf miss ratio = -nan%
L1$:
  accesses   = 582033
  misses     = 79
  miss ratio = 0.01%
  pf accesses   = 5411
  pf misses     = 58
  pf miss ratio = 1.07%
L2$:
  accesses   = 123
  misses     = 123
  miss ratio = 100.00%
  pf accesses   = 58
  pf misses     = 58
  pf miss ratio = 100.00%
L3$:
  accesses   = 123
  misses     = 89
  miss ratio = 72.36%
  pf accesses   = 58
  pf misses     = 28
  pf miss ratio = 48.28%
---------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------Prefetcher (Full Simulation i.e. No Warmup)----------------------------------------------
Num Trainings :417260
Num Prefetches generated :5432
Num Prefetches issued :14837
Num Prefetches filtered by PF queue :52
Num untimely prefetches dropped from PF queue :21
Num prefetches not issued LDST contention :9426
Num prefetches not issued stride 0 :139934
---------------------------------------------------------------------------------------------------------------------------------------

-------------------------------ILP LIMIT STUDY (Full Simulation i.e. Counts Not Reset When Warmup Ends)--------------------------------
instructions = 997741
cycles       = 193123
CycWP        = 61660
IPC          = 5.1663

---------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------BRANCH PREDICTION MEASUREMENTS (Full Simulation i.e. Counts Not Reset When Warmup Ends)----------------------------------------------
Type                   NumBr     MispBr        mr     mpki
CondDirect           111265       1140   1.0246%   0.8680
JumpDirect            26868          0   0.0000%   0.0000
JumpIndirect              1          0   0.0000%   0.0000
JumpReturn            10589          0   0.0000%   0.0000
Not control         1164572          0   0.0000%   0.0000
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------DIRECT CONDITIONAL BRANCH PREDICTION MEASUREMENTS (Last 10M instructions)-----------------------------------------------------
       Instr       Cycles      IPC      NumBr     MispBr BrPerCyc MispBrPerCyc        MR     MPKI      CycWP   CycWPAvg   CycWPPKI
      997741       193123   5.1663     111265       1140   0.5761       0.0059   1.0246%   1.1426      61660    54.0877    61.7996
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------DIRECT CONDITIONAL BRANCH PREDICTION MEASUREMENTS (Last 25M instructions)-----------------------------------------------------
       Instr       Cycles      IPC      NumBr     MispBr BrPerCyc MispBrPerCyc        MR     MPKI      CycWP   CycWPAvg   CycWPPKI
      997741       193123   5.1663     111265       1140   0.5761       0.0059   1.0246%   1.1426      61660    54.0877    61.7996
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------DIRECT CONDITIONAL BRANCH PREDICTION MEASUREMENTS (50 Perc instructions)---------------------------------------------------
       Instr       Cycles      IPC      NumBr     MispBr BrPerCyc MispBrPerCyc        MR     MPKI      CycWP   CycWPAvg   CycWPPKI
      997741       193123   5.1663     111265       1140   0.5761       0.0059   1.0246%   1.1426      61660    54.0877    61.7996
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------DIRECT CONDITIONAL BRANCH PREDICTION MEASUREMENTS (Full Simulation i.e. Counts Not Reset When Warmup Ends)-------------------------------------
       Instr       Cycles      IPC      NumBr     MispBr BrPerCyc MispBrPerCyc        MR     MPKI      CycWP   CycWPAvg   CycWPPKI
      997741       193123   5.1663     111265       1140   0.5761       0.0059   1.0246%   1.1426      61660    54.0877    61.7996
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Read 997741 instrs 

```


## Sample Output if using python script for all the traces:

```
python scripts/trace_exec_training_list.py  --trace_dir ./sample_traces/ --results_dir  sample_results
Got 2 traces
Begin processing run:fp/sample_fp_trace
Begin processing run:int/sample_int_trace
Extracting data from : sample_results/fp/sample_fp_trace.log |  WL:fp | Run:sample_fp_trace
Extracting data from : sample_results/int/sample_int_trace.log |  WL:int | Run:sample_int_trace
  Workload               Run  TraceSize Status            ExecTime   Instr  Cycles     IPC   NumBr MispBr BrPerCyc MispBrPerCyc       MR    MPKI  CycWP  CycWPAvg CycWPPKI 50PercInstr 50PercCycles 50PercIPC 50PercNumBr 50PercMispBr 50PercBrPerCyc 50PercMispBrPerCyc 50PercMR 50PercMPKI 50PercCycWP 50PercCycWPAvg 50PercCycWPPKI
0       fp   sample_fp_trace   1.178618   Pass   6.901926040649414  997741  193123  5.1663  111265   1140   0.5761       0.0059  1.0246%  1.1426  61660   54.0877  61.7996      997741       193123    5.1663      111265         1140         0.5761             0.0059  1.0246%     1.1426       61660        54.0877        61.7996
1      int  sample_int_trace   1.334165   Pass  5.5803234577178955  997301  338310  2.9479  128874    264   0.3809       0.0008  0.2049%  0.2647  33348  126.3182  33.4382      997301       338310    2.9479      128874          264         0.3809             0.0008  0.2049%     0.2647       33348       126.3182        33.4382


----------------------------------Aggregate Metrics Per Workload Category----------------------------------

WL:fp         Branch Misprediction PKI(BrMisPKI) AMean : 1.1426
WL:fp         Cycles On Wrong-Path PKI(CycWpPKI) AMean : 61.7996
WL:int        Branch Misprediction PKI(BrMisPKI) AMean : 0.2647
WL:int        Cycles On Wrong-Path PKI(CycWpPKI) AMean : 33.4382
-----------------------------------------------------------------------------------------------------------


---------------------------------------------Aggregate Metrics---------------------------------------------

Branch Misprediction PKI(BrMisPKI) AMean : 0.70365
Cycles On Wrong-Path PKI(CycWpPKI) AMean : 47.6189
-----------------------------------------------------------------------------------------------------------
```




### Explaining the data we have from the interface

# Branch Predictor API Guide

This document explains all the features and data available for implementing branch predictors in this project.

## Overview

Your predictor is a **class** that implements these methods:
- `setup()` - Called once at the start of simulation
- `predict(seq_no, piece, PC)` - Make a prediction for a conditional branch
- `history_update(seq_no, piece, PC, taken, nextPC)` - Update history after prediction (speculative)
- `update(seq_no, piece, PC, resolveDir, predDir, nextPC)` - Update predictor when branch resolves
- `terminate()` - Called once at the end of simulation

---

## 1. Pipeline Stage Callbacks

The simulator calls your predictor at different pipeline stages. You can use information from ANY stage:

### `beginCondDirPredictor()`
- **When**: Once at simulation start
- **Use**: Initialize your predictor data structures (tables, history, counters, etc.)
- **Available**: Nothing specific - use for setup

### `notify_instr_fetch(seq_no, piece, pc, fetch_cycle)`
- **When**: Every instruction fetched (NOT just branches)
- **Available Data**:
  - `seq_no`: Unique sequential instruction number (increments for each instruction)
  - `piece`: For SIMD instructions, some operations are split into pieces (usually 0)
  - `pc`: Program counter (64-bit address) of the instruction
  - `fetch_cycle`: Cycle number when instruction was fetched
- **Use Cases**:
  - Track instruction fetch patterns
  - Build prefetch/history data
  - See ALL instructions, not just branches

### `get_cond_dir_prediction(seq_no, piece, pc, pred_cycle)` ⭐ MAIN PREDICTION
- **When**: Only for conditional branches, right before execution
- **Must Return**: `bool` - `true` = taken, `false` = not taken
- **Available Data**:
  - `seq_no`: Sequential instruction number
  - `piece`: Usually 0
  - `pc`: Program counter of the branch
  - `pred_cycle`: Cycle when prediction is made
- **What You Can Use**:
  - PC (hash into tables)
  - Global history (updated in `spec_update`)
  - Local history (your own tables)
  - Previous predictions/outcomes
  - **Everything from `notify_instr_fetch`** (you can track state per PC)

### `spec_update(seq_no, piece, pc, inst_class, resolve_dir, pred_dir, next_pc)`
- **When**: Right after prediction, for ALL branches (conditional + unconditional)
- **Timing**: Called SPECULATIVELY - outcome might be wrong!
- **Available Data**:
  - `inst_class`: Type of branch (see InstClass enum below)
  - `resolve_dir`: Actual outcome (taken/not taken) - this is the CORRECT answer
  - `pred_dir`: What you predicted (might be wrong!)
  - `next_pc`: Target PC if taken
- **Use Cases**:
  - Update Global History Register (GHR) immediately
  - Update speculative state
  - Track branch types for different histories

### `notify_instr_decode(seq_no, piece, pc, decode_info, decode_cycle)`
- **When**: When instruction is decoded
- **Available Data**:
  - `decode_info`: Contains instruction class, register info (see DecodeInfo below)
  - `decode_cycle`: Cycle when decoded
- **Use Cases**:
  - See register dependencies
  - Identify instruction types early
  - See source/destination registers

### `notify_agen_complete(seq_no, piece, pc, decode_info, mem_va, mem_sz, agen_cycle)`
- **When**: When load/store address generation completes
- **Available Data**:
  - `mem_va`: Virtual memory address (if load/store)
  - `mem_sz`: Memory access size
- **Use Cases**:
  - Correlate memory access patterns with branches
  - Use memory addresses as features

### `notify_instr_execute_resolve(seq_no, piece, pc, pred_dir, exec_info, execute_cycle)` ⭐ MAIN UPDATE
- **When**: When branch actually executes and resolves
- **Timing**: This is when you know the TRUE outcome
- **Available Data**:
  - `pred_dir`: What you predicted earlier
  - `exec_info`: Contains actual outcome and more (see ExecuteInfo below)
- **Use Cases**:
  - Update predictor tables with correct outcome
  - Train perceptrons, update counters
  - Learn from mistakes

### `notify_instr_commit(seq_no, piece, pc, pred_dir, exec_info, commit_cycle)`
- **When**: When instruction commits (retirement)
- **Use Cases**:
  - Final state updates
  - Statistics collection
  - Cleanup

### `endCondDirPredictor()`
- **When**: At end of simulation
- **Use**: Print statistics, dump state, cleanup

---

## 2. Data Structures

### InstClass (enum)
Branch types you can distinguish:
```cpp
enum class InstClass {
    condBranchInstClass = 3,           // Conditional branch (what you predict!)
    uncondDirectBranchInstClass = 4,   // Unconditional direct branch
    uncondIndirectBranchInstClass = 5, // Indirect branch (jump to register)
    callDirectInstClass = 9,           // Direct function call
    callIndirectInstClass = 10,        // Indirect function call
    ReturnInstClass = 11,              // Return instruction
    // ... other instruction types
};
```

### DecodeInfo
Available in `notify_instr_decode`:
```cpp
struct DecodeInfo {
    InstClass insn_class;                    // Instruction type
    std::vector<uint64_t> src_reg_info;     // Source register IDs
    std::optional<uint64_t> dst_reg_info;   // Destination register ID (if any)
};
```

### ExecuteInfo
Available in `notify_instr_execute_resolve` and `notify_instr_commit`:
```cpp
struct ExecuteInfo {
    DecodeInfo dec_info;                    // Decode info (see above)
    std::optional<bool> taken;              // Actual taken/not-taken (for branches)
    uint64_t next_pc;                       // Next PC (fall-through or target)
    std::optional<uint64_t> taken_target;   // Target PC if taken
    std::optional<uint64_t> mem_va;         // Memory address (if load/store)
    std::optional<uint64_t> mem_sz;         // Memory size (if load/store)
    std::optional<uint64_t> dst_reg_value;  // Register value written
};
```

---

## 3. Key Identifiers

### `seq_no` (Sequence Number)
- **Unique ID** for each instruction in program order
- Increments for every instruction (even non-branches)
- **Use**: Track instruction order, build history sequences
- **Example**: Branch at seq_no=1000, next branch at seq_no=1045

### `piece`
- Usually 0 for normal instructions
- For SIMD/vector instructions, operations split into pieces
- **Use**: Usually ignore (always 0 for branches)

### `pc` (Program Counter)
- 64-bit instruction address
- **Use**: 
  - Hash into prediction tables
  - Index pattern history tables
  - Distinguish different branches
  - Extract bits for hashing

---

## 4. What You Can Track/Store

### ✅ Allowed:
- **Prediction tables**: Arrays indexed by PC hash
- **History registers**: Global/Local history (bits)
- **Counters**: Saturated counters, perceptron weights
- **PC-based structures**: Pattern history tables, target predictors
- **Statistics**: Counters for accuracy, confidence
- **State machines**: TAGE-style state machines

### ❌ Not Available:
- Can't modify simulator state
- Can't see future instructions (only past via history)
- Can't directly access memory/cache (but can see addresses in callbacks)

---

## 5. Common Predictor Patterns

### Simple Bimodal Predictor
```cpp
bool predict(uint64_t seq_no, uint8_t piece, uint64_t PC) {
    uint32_t index = PC % TABLE_SIZE;
    return counters[index] >= 2;  // Threshold
}

void update(...) {
    if (resolveDir == predDir) {
        counters[index] = saturate_increment(counters[index]);
    } else {
        counters[index] = saturate_decrement(counters[index]);
    }
}
```

### Global History Predictor (GShare)
```cpp
uint64_t global_history = 0;  // Track in your class

bool predict(uint64_t seq_no, uint8_t piece, uint64_t PC) {
    uint32_t index = (PC ^ global_history) % TABLE_SIZE;
    return counters[index] >= 2;
}

void history_update(...) {
    global_history = (global_history << 1) | (taken ? 1 : 0);
    global_history &= HISTORY_MASK;  // Keep fixed width
}
```

### Perceptron Predictor
```cpp
int weights[N][HISTORY_LENGTH];

bool predict(uint64_t seq_no, uint8_t piece, uint64_t PC) {
    int sum = weights[PC % N][0];  // Bias
    for (int i = 0; i < HISTORY_LENGTH; i++) {
        if (global_history & (1 << i)) {
            sum += weights[PC % N][i+1];
        } else {
            sum -= weights[PC % N][i+1];
        }
    }
    return sum >= 0;
}
```

---

## 6. Timing Notes

**Important**: The simulator runs out-of-order, so:
- `spec_update` happens **immediately** after prediction (speculative)
- `notify_instr_execute_resolve` happens **later** when branch executes
- Instructions can execute out of order!
- Use `seq_no` to track program order if needed

**Example Timeline**:
1. Instruction at seq_no=100 predicted → `get_cond_dir_prediction` called
2. `spec_update` called immediately (speculative history update)
3. Many more instructions fetched/predicted...
4. Eventually, seq_no=100 executes → `notify_instr_execute_resolve` called
5. Update predictor with true outcome

---

## 7. Example: What Data is Available When?

### Predicting a Branch:
```
You have:
- PC (64-bit address)
- seq_no (instruction order)
- Your internal state (history, tables)
- Previous branch outcomes (via your history)
```

### Updating After Prediction:
```
You get:
- resolve_dir (correct answer!)
- pred_dir (what you predicted)
- next_pc (target address)
- You can update speculative history
```

### When Branch Executes:
```
You get:
- ExecuteInfo with full details
- Actual taken/not-taken
- Memory addresses (if load/store before this branch)
- Register values
- You can update tables with true outcome
```

---

## 8. Tips for Implementation

1. **Use PC bits**: Hash PC to index tables: `index = (PC >> 2) & MASK`
2. **Track history**: Global/Local history are powerful features
3. **Combine predictors**: Can use multiple simple predictors together
4. **Watch timing**: Update history speculatively, update tables on resolve
5. **Use seq_no**: Track program order if needed for correct updates
6. **Memory budget**: You have up to 128KB additional (on top of TAGE-SC-L's 64KB)

---

## Summary Checklist

What you CAN use:
- ✅ PC (program counter) - hash/index into tables
- ✅ seq_no - instruction order
- ✅ Global/Local history (build yourself)
- ✅ Previous predictions/outcomes
- ✅ Instruction types (conditional, indirect, etc.)
- ✅ Register information (from decode)
- ✅ Memory addresses (from agen)
- ✅ Cycle timestamps
- ✅ Any internal state you maintain

What you CANNOT use:
- ❌ Future instructions (only past via history)
- ❌ Direct memory access
- ❌ Other predictors' internal state (except TAGE-SC-L via provided interface)

**Your predictor is a class - you can store ANY state you want as member variables!**

