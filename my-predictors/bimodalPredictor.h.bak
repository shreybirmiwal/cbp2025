#ifndef _BIMODAL_PREDICTOR_H_
#define _BIMODAL_PREDICTOR_H_
#include <stdlib.h>
#include <stdint.h>

//RESULTS
//TABLE_SIZE  Type                   NumBr     MispBr        mr     mpki
//1           CondDirect           111265      40993  36.8427%  41.0858
//100   CondDirect           111265      29577  26.5825%  29.6440
//1000 CondDirect           111265       2607   2.3431%   2.6129
//10000 CondDirect           111265       2616   2.3511%   2.6219
//100000 CondDirect           111265       2616   2.3511%   2.6219
//1000000 CondDirect           111265       2616   2.3511%   2.6219
class BimodalPredictor
{
        
    public:

        static const int TABLE_SIZE = 100000;
        int table[TABLE_SIZE]; //1000 rows, 2 bit saturated counter

        BimodalPredictor (void){
            for (int i = 0; i < TABLE_SIZE; i++) {
                table[i] = 4;
            }
        }
        void setup(){}
        void terminate(){}

        bool predict (uint64_t seq_no, uint8_t piece, uint64_t PC)
        {
            return table[PC % TABLE_SIZE] > 1;
        }
        void history_update (uint64_t seq_no, uint8_t piece, uint64_t PC, bool taken, uint64_t nextPC){}

        //once resolved
        void update (uint64_t seq_no, uint8_t piece, uint64_t PC, bool resolveDir, bool predDir, uint64_t nextPC){
            int saturatedCounter = table[PC % TABLE_SIZE];
            
            if (resolveDir == true) {
                if (saturatedCounter < 3) {
                    saturatedCounter++;
                }
            }
            else {
                if (saturatedCounter > 0) {
                    saturatedCounter--;
                }
            }

            table[PC % TABLE_SIZE] = saturatedCounter;

            return;

        }

};
// =================
// Predictor End
// =================

static BimodalPredictor bimodal_predictor;

#endif