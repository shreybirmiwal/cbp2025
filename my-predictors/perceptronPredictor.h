#ifndef _PERCEPTRON_PREDICTOR_H_
#define _PERCEPTRON_PREDICTOR_H_
#include <stdlib.h>
#include <stdint.h>

class PerceptronPredictor
{
    bool prevCorrectDecision = false;
    public:

        PerceptronPredictor (void){}
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

static PerceptronPredictor perceptron_predictor;

#endif