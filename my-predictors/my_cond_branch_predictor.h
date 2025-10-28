#ifndef _PREDICTOR_H_
#define _PREDICTOR_H_
#include <stdlib.h>

class SampleCondPredictor
{
    bool prevCorrectDecision = false;
    public:

        SampleCondPredictor (void){}
        void setup(){}
        void terminate(){}

        bool predict (uint64_t seq_no, uint8_t piece, uint64_t PC)
        {
            return prevCorrectDecision;
        }
        void history_update (uint64_t seq_no, uint8_t piece, uint64_t PC, bool taken, uint64_t nextPC){}

        void update (uint64_t seq_no, uint8_t piece, uint64_t PC, bool resolveDir, bool predDir, uint64_t nextPC){
            prevCorrectDecision = resolveDir;
        }

};
// =================
// Predictor End
// =================

#endif
static SampleCondPredictor cond_predictor_impl;