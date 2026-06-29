//+------------------------------------------------------------------+
//|                                          EAZigZagFiboPattern.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| DEFINES                                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| INCLUDES                                                         |
//+------------------------------------------------------------------+
#include <modulos/ZigzagController.mqh>
#include <modulos/HarmonicPatterns.mqh>
#include <modulos/EATimeframes.mqh>
#include <modulos/EACore.mqh>
//+------------------------------------------------------------------+
//| EXTERN                                                   |
//+------------------------------------------------------------------+
extern string  Zigzag_info              = "=== ZIGZAG SETUP ===";
extern bool    ZupVisualDebug           = false;
extern ZIGZAG_TYPE zigzag_type          = ZZ_MT4;
extern int     zigzag_fibo_shift        = 3;
extern bool    useZigZagCustonValues    = true;
extern string  zigzagFiboCustonValuesStr = "{1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946};";
extern int     zigzag_fiboPos_setup1    = 9;
extern int     zigzag_fiboPos_setup2    = 8;
extern int     zigzag_fiboPos_setup3    = 8;
extern int     zigzag_fiboPos_setup4    = 7;
extern int     zigzag_fiboPos_setup5    = 6;
extern int     zigzag_fiboPos_setup6    = 5;
extern int     zigzag_fiboPos_setup7    = 5;
extern string  Zigzag_setup               = "=== ZIGZAG SIGNAL ===";
extern bool    use_zigzag_size            = false;
extern double  zz_CD_size_MIN             = 0.0;
extern double  zz_CD_size_MAX             = 0.0;
extern double  zz_BC_size_MIN             = 0.0;
extern double  zz_BC_size_MAX             = 0.0;
extern double  zz_AB_size_MIN             = 0.0;
extern double  zz_AB_size_MAX             = 0.0;
extern double  zz_XA_size_MIN             = 0.0;
extern double  zz_XA_size_MAX             = 0.0;
extern bool    use_zigzag_angle           = false;
extern double  zz_CD_angle_MIN            = 0.0;
extern double  zz_CD_angle_MAX            = 0.0;
extern double  zz_BC_angle_MIN            = 0.0;
extern double  zz_BC_angle_MAX            = 0.0;
extern double  zz_AB_angle_MIN            = 0.0;
extern double  zz_AB_angle_MAX            = 0.0;
extern double  zz_XA_angle_MIN            = 0.0;
extern double  zz_XA_angle_MAX            = 0.0;
extern string  fibonacci_signal           = "=== FIBONACCI SIGNAL ===";
extern bool    use_fiboPatterns           = true;
extern string  fibo_numbers_string        = "0.146,0.236,0.382,0.447,0.5,0.618,0.707,0.786,0.886,1.0,1.128,1.272,1.414,1.618,2.0,2.236,2.618,3.1416,3.618,4.236";
extern ZZ_FIBO_PATTERN fibo_pattern_main  = BD_PATTERN;
extern string  fibo_BD_patterns            = "1.0,1.272,1.618,2.0,2.236,2.618,3.1416";
extern string  fibo_AC_patterns            = "";
extern string  fibo_XB_patterns            = "";
extern string  fibo_XD_patterns            = "";
extern string  fibo_AD_patterns            = "";
extern double  fibo_patterns_delta         = 0.04;
extern bool    update_currentFiboBD        = false;
extern string  fibo_strong1_patterns       = "1.272,1.618,2.0,2.272,2.618,3.1416";
extern string  fibo_strong2_patterns       = "1.618,2.0,2.272,2.618,3.1416";
extern string  fibo_strong3_patterns       = "2.0,2.272,2.618,3.1416";
extern string  fibo_strong4_patterns       = "2.272,2.618,3.1416";
extern string  fibo_weak1_patterns         = "0.618,1.0,1.618,2.0,2.618,3.1416";
extern string  fibo_weak2_patterns         = "0.5,0.618,1.0,1.618,2.0,2.618,3.1416";
extern string  fibo_weak3_patterns         = "0.382,0.5,0.618,1.0,1.618,2.0,2.618,3.1416";
extern string  fibo_weak4_patterns         = "0.236,0.382,0.5,0.618,1.0,1.618,2.0,2.618,3.1416";
extern bool    use_fiboMinMax              = false;
extern double  fibo_BD_MIN                 = 0.0;
extern double  fibo_BD_MAX                 = 0.0;
extern double  fibo_AC_MIN                 = 0.0;
extern double  fibo_AC_MAX                 = 0.0;
extern double  fibo_XB_MIN                 = 0.0;
extern double  fibo_XB_MAX                 = 0.0;
extern double  fibo_XD_MIN                 = 0.0;
extern double  fibo_XD_MAX                 = 0.0;
extern string  HarmonicPatterns_info      = "=== HARMONIC PATTERNS SETUP ===";
extern bool    useHarmonicPatterns        = false;

//+------------------------------------------------------------------+
//| FIBONACCI NUMBERS                                                |
//+------------------------------------------------------------------+
int fibonacciSequence[20] = {1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946};
double fibonacciNumbers[20] = {0.146,0.236,0.382,0.447,0.5,0.618,0.707,0.786,0.886,1.0,1.128,1.272,1.414,1.618,2.0,2.236,2.618,3.1416,3.618,4.236};
int fibonacciSequence_count = 20;

//+------------------------------------------------------------------+
//| ZigZagFiboPattern Class                                          |
//+------------------------------------------------------------------+
class EAZigZagFiboPattern
{
   EATimeframes* timeframes;
   EACore* core;

   bool useZigZag, use_fiboMM;
//+------------------------------------------------------------------+
//| ZIGZAG
//+------------------------------------------------------------------+
   ZigzagController *zzCtrl[][TF_COUNT];
   GeometrySettings *settings[][TF_COUNT];
   bool zupInitializedBySetup[][TF_COUNT], zupInitializedBySymbol[], zupInitialized;
   bool buySignalByZzSizeSetup[][TF_COUNT], sellSignalByZzSizeSetup[][TF_COUNT];
   bool buySignalByZzAngleSetup[][TF_COUNT], sellSignalByZzAngleSetup[][TF_COUNT];
   int setupValue[TF_COUNT][3];
//+------------------------------------------------------------------+
//| HARMONIC PATTERNS
//+------------------------------------------------------------------+
   HarmonicPatterns* harmonicPatterns[][TF_COUNT];
   bool buySignalByHarmonicSetup[][TF_COUNT], sellSignalByHarmonicSetup[][TF_COUNT];
//+------------------------------------------------------------------+
//| FIBONACCI VARS
//+------------------------------------------------------------------+
   int fibo_BD_pattern_size, fibo_AC_pattern_size, fibo_XB_pattern_size, fibo_XD_pattern_size, fibo_AD_pattern_size;
   double fibo_BD_pattern_values[], fibo_AC_pattern_values[], fibo_XB_pattern_values[], fibo_XD_pattern_values[], fibo_AD_pattern_values[];
   double fibo_BD_delta_values[][2], fibo_AC_delta_values[][2], fibo_XB_delta_values[][2], fibo_XD_delta_values[][2], fibo_AD_delta_values[][2];
   int fibo_strong_size[4], fibo_weak_size[4];

   double fibo_strong1_values[], fibo_strong2_values[], fibo_strong3_values[], fibo_strong4_values[];
   double fibo_strong1_delta_values[][2], fibo_strong2_delta_values[][2], fibo_strong3_delta_values[][2], fibo_strong4_delta_values[][2];
   double fibo_weak1_values[], fibo_weak2_values[], fibo_weak3_values[], fibo_weak4_values[];
   double fibo_weak1_delta_values[][2], fibo_weak2_delta_values[][2], fibo_weak3_delta_values[][2], fibo_weak4_delta_values[][2];
   double fibo_lastMatchFibo[][TF_COUNT], fibo_lastTradeFibo[][TF_COUNT];
   int fibo_lastMatchFiboPos[][TF_COUNT], fibo_lastTradeFiboPos[][TF_COUNT];
   int fibo_lastTradeType[][TF_COUNT];
   bool buySignalByFiboPatternSetup[][TF_COUNT], sellSignalByFiboPatternSetup[][TF_COUNT], buySignalByFiboMinMaxSetup[][TF_COUNT], sellSignalByFiboMinMaxSetup[][TF_COUNT];

//+------------------------------------------------------------------+
//| FUNCTIONS GET SET
//+------------------------------------------------------------------+
public:
   bool ZupInitialized() { return zupInitialized; }
   bool ZupInitializedBySymbol(int iSym) { return zupInitializedBySymbol[iSym]; }
   bool ZupInitializedBySetup(int iSym, int iSet) { return zupInitializedBySetup[iSym][iSet]; }
   bool UseZigZag() { return useZigZag; }
   double LastMatchFibo(int iSym, int iSet) { return fibo_lastMatchFiboPos[iSym][iSet]; }
   int SetupValue(int tf, int pos) { return setupValue[tf][pos]; }

//+------------------------------------------------------------------+
//| CONSTRUCTOR
//+------------------------------------------------------------------+
   EAZigZagFiboPattern(EACore* _core, EATimeframes* _timeframes)
   {
      timeframes = _timeframes;
      core = _core;
      zupInitialized = false;
      useZigZag = (use_zigzag_angle || use_zigzag_size || useHarmonicPatterns || use_fiboPatterns || use_fiboMinMax || use_fiboMM);

      int setupCustonPos[TF_COUNT];
      ArrayInitialize(setupValue,0);
      ArrayInitialize(setupCustonPos,0);
      ArrayResize(buySignalByZzSizeSetup, core.getSymbolCount() ); ArrayInitialize(buySignalByZzSizeSetup, false);
      ArrayResize(sellSignalByZzSizeSetup, core.getSymbolCount() ); ArrayInitialize(sellSignalByZzSizeSetup, false);
      ArrayResize(buySignalByZzAngleSetup, core.getSymbolCount() ); ArrayInitialize(buySignalByZzAngleSetup, false);
      ArrayResize(sellSignalByZzAngleSetup, core.getSymbolCount() ); ArrayInitialize(sellSignalByZzAngleSetup, false);
      ArrayResize(buySignalByFiboPatternSetup, core.getSymbolCount() ); ArrayInitialize(buySignalByFiboPatternSetup, false);
      ArrayResize(sellSignalByFiboPatternSetup, core.getSymbolCount() ); ArrayInitialize(sellSignalByFiboPatternSetup, false);
      ArrayResize(buySignalByFiboMinMaxSetup, core.getSymbolCount() ); ArrayInitialize(buySignalByFiboMinMaxSetup, false);
      ArrayResize(sellSignalByFiboMinMaxSetup, core.getSymbolCount() ); ArrayInitialize(sellSignalByFiboMinMaxSetup, false);
      ArrayResize(buySignalByHarmonicSetup, core.getSymbolCount() ); ArrayInitialize(buySignalByHarmonicSetup, false);
      ArrayResize(sellSignalByHarmonicSetup, core.getSymbolCount() ); ArrayInitialize(sellSignalByHarmonicSetup, false);

      if(useZigZagCustonValues){
      	setupCustonPos[0] = zigzag_fiboPos_setup1;
      	setupCustonPos[1] = zigzag_fiboPos_setup2;
      	setupCustonPos[2] = zigzag_fiboPos_setup3;
      	setupCustonPos[3] = zigzag_fiboPos_setup4;
      	setupCustonPos[4] = zigzag_fiboPos_setup5;
      	setupCustonPos[5] = zigzag_fiboPos_setup6;
      	setupCustonPos[6] = zigzag_fiboPos_setup7;
      }

      if(zigzag_type == ZZ_MT4){
   		for(int i=0; i<TF_COUNT; i++){
   			//[0]depth  [1]deviation [2]backstep
   			int pos = i;
   			if(useZigZagCustonValues){
   				pos = setupCustonPos[i];
   			}
   			setupValue[i][0] = fibonacciSequence[pos];
   			setupValue[i][1] = fibonacciSequence[pos-2];
   			setupValue[i][2] = fibonacciSequence[pos-3];
   			logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing Setup ",i," with ZZ_MT4 TF ",timeframes.Value(i), " (",setupValue[i][0],",",setupValue[i][1],",",setupValue[i][2],")" ));
   		}
      }
      else if(zigzag_type == CZIGZAG){
      		if(useZigZagCustonValues){
      			for(int i=0; i<TF_COUNT; i++){
   	   			setupValue[i][0] = fibonacciSequence[setupCustonPos[i]];
   	   			setupValue[i][1] = fibonacciSequence[setupCustonPos[i]-2];
   	   			logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing Setup ",i," with CZIGZAG TF ",timeframes.Value(i), " (",setupValue[i][0],",",setupValue[i][1],")" ));
   	   		}
   	   	}
      		else{
   			setupValue[0][0] = 13;
   			setupValue[0][1] = 5;
   			setupValue[1][0] = 55;
   			setupValue[1][1] = 21;
   			setupValue[2][0] = 144;
   			setupValue[2][1] = 55;
   			setupValue[3][0] = 233;
   			setupValue[3][1] = 89;
   			setupValue[4][0] = 377;
   			setupValue[4][1] = 144;
   			setupValue[5][0] = 610;
   			setupValue[5][1] = 233;
   			setupValue[6][0] = 987;
   			setupValue[6][1] = 377;
      		}

      }
      else if(zigzag_type == ZZ_NEM4){
      	for(int i=0; i<TF_COUNT; i++){
      		int pos = i;
      		if(useZigZagCustonValues){
      			pos = setupCustonPos[i];
      		}
      		setupValue[i][0] = fibonacciSequence[pos-1];
      		setupValue[i][1] = fibonacciSequence[pos-2];
      		setupValue[i][2] = fibonacciSequence[pos];
      		logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing Setup ",i," with ZZ_NEM4 TF ",timeframes.Value(i), " (",setupValue[i][0],",",setupValue[i][1],",",setupValue[i][2],")" ));
      	}
      }
      if(useZigZag){
         ArrayResize(zzCtrl, core.getSymbolCount() );
         ArrayResize(settings, core.getSymbolCount() );
         ArrayResize(zupInitializedBySetup, core.getSymbolCount() ); ArrayInitialize(zupInitializedBySetup, false);
         ArrayResize(zupInitializedBySymbol, core.getSymbolCount() ); ArrayInitialize(zupInitializedBySymbol, false);
      }
      if(use_fiboPatterns){
         InitializeFiboPattern(fibo_BD_pattern_values, fibo_BD_delta_values, fibo_BD_pattern_size, fibo_BD_patterns, "BD");
         InitializeFiboPattern(fibo_AC_pattern_values, fibo_AC_delta_values, fibo_AC_pattern_size, fibo_AC_patterns, "AC");
         InitializeFiboPattern(fibo_XB_pattern_values, fibo_XB_delta_values, fibo_XB_pattern_size, fibo_XB_patterns, "XB");
         InitializeFiboPattern(fibo_XD_pattern_values, fibo_XD_delta_values, fibo_XD_pattern_size, fibo_XD_patterns, "XD");
         InitializeFiboPattern(fibo_AD_pattern_values, fibo_AD_delta_values, fibo_AD_pattern_size, fibo_AD_patterns, "AD");
         ArrayResize(fibo_lastMatchFibo, core.getSymbolCount() ); ArrayInitialize(fibo_lastMatchFibo, 0.0);
         ArrayResize(fibo_lastTradeType, core.getSymbolCount() ); ArrayInitialize(fibo_lastTradeType, 0);
         ArrayResize(fibo_lastTradeFibo, core.getSymbolCount() ); ArrayInitialize(fibo_lastTradeFibo, 0.0);
         InitializeFiboWeakStrong();
      }
      ArrayResize(fibo_lastMatchFiboPos, core.getSymbolCount() ); ArrayInitialize(fibo_lastMatchFiboPos, 0);
      ArrayResize(fibo_lastTradeFiboPos, core.getSymbolCount() ); ArrayInitialize(fibo_lastTradeFiboPos, 0);

      if(useHarmonicPatterns){
         ArrayResize(harmonicPatterns, core.getSymbolCount() );
      }
   }
//+------------------------------------------------------------------+
   ~EAZigZagFiboPattern(){
      for (int _iSymbol = 0; _iSymbol < core.getSymbolCount() ; _iSymbol++)
      {
         for(int iSetup=0; iSetup < TF_COUNT; iSetup++){
            if(timeframes.InUse(iSetup)){
               if(useZigZag){
                  if(settings[_iSymbol][iSetup] != NULL) delete(settings[_iSymbol][iSetup]);
                  if(zzCtrl[_iSymbol][iSetup] != NULL) delete(zzCtrl[_iSymbol][iSetup]);
                  if(useHarmonicPatterns)
                     if(harmonicPatterns[_iSymbol][iSetup] != NULL) delete(harmonicPatterns[_iSymbol][iSetup]);
               }
            }
         }
      }
   }
//+------------------------------------------------------------------+
void updateLastTradeFibo(int iSym, int iSet, int order_type_entry)
{
   if(use_fiboPatterns){
      fibo_lastTradeFibo[iSym][iSet] = fibo_lastMatchFibo[iSym][iSet];
      fibo_lastTradeFiboPos[iSym][iSet] = fibo_lastMatchFiboPos[iSym][iSet];
      fibo_lastTradeType[iSym][iSet] = order_type_entry;
   }
}
//+------------------------------------------------------------------+
//| FUNCTIONS
//+------------------------------------------------------------------+
   void InitZUP()
   {
      for(int iSymbol=0; iSymbol < core.getSymbolCount(); iSymbol++)
      {
         TYPE_EXECUTION execution = EXECUTION_EA;
         if(ZupVisualDebug && core.getSymbol(iSymbol) == Symbol())
            execution = EXECUTION_DEBUG;

         for(int iSetup=0; iSetup < TF_COUNT; iSetup++)
         {
            if(timeframes.InUse(iSetup) && !zupInitializedBySetup[iSymbol][iSetup])
            {
               settings[iSymbol][iSetup] = new GeometrySettings();
               int _init = settings[iSymbol][iSetup].initSettings(core.getSymbol(iSymbol), timeframes.Value(iSetup),
                  core.getSymbolDigits(iSymbol) ,core.getSymbolPoint(iSymbol), zigzag_type,
                  setupValue[iSetup][0], setupValue[iSetup][1], setupValue[iSetup][2],
                  execution, allTicks, (use_fiboPatterns && update_currentFiboBD),use_zigzag_angle, use_zigzag_size );

               if(_init != INIT_SUCCEEDED){
                  //logMessage(LOG_ERROR, symbol, timeframe, "initZUP", "initSymbolInfo() FAILED: "+settings[iSymbol][iSetup].error);
                  delete(settings[core.getSymbolPos()][iSetup]);
                  continue;
               }
               zzCtrl[iSymbol][iSetup] = new ZigzagController(settings[iSymbol][iSetup]);
               _init = zzCtrl[iSymbol][iSetup].initZigZag();
               if(_init != INIT_SUCCEEDED){
                  logMessage(LOG_ERROR, core.getSymbol(iSymbol), timeframes.DefaultValue(), "initZUP", "ZupController.initZigZag()() FAILED!");
                  delete(zzCtrl[iSymbol][iSetup]);
                  continue;
               }
               if(useHarmonicPatterns){
                  harmonicPatterns[iSymbol][iSetup] = new HarmonicPatterns();
               }
               zupInitializedBySetup[iSymbol][iSetup] = true;
            }
         }
         zupInitializedBySymbol[iSymbol] = true;
         for(int iSetup=0; iSetup<TF_COUNT; iSetup++){
            if(timeframes.InUse(iSetup)) zupInitializedBySymbol[iSymbol] = zupInitializedBySymbol[iSymbol] && zupInitializedBySetup[iSymbol][iSetup];
         }
      }
   }
   //+------------------------------------------------------------------+
   bool matchFiboPattern(int iSymbol, int iSetup, double &fibo_pattern_values[], double &fibo_delta_values[][], int fibo_pattern_size, double fibo, bool setLastFiboMatched){
      bool matched = false;
      for(int i=0; i<fibo_pattern_size; i++){
         if(fibo >= fibo_delta_values[i][0] && fibo <= fibo_delta_values[i][1]){
            matched = true;
            if(setLastFiboMatched){
               fibo_lastMatchFibo[iSymbol][iSetup] = fibo_pattern_values[i];
               fibo_lastMatchFiboPos[iSymbol][iSetup] = i;
            }
            break;
         }
      }
      return matched;
   }
   //+------------------------------------------------------------------+
   void InitializeFiboPattern(double &fibo_pattern_values[], double &fibo_delta_values[][], int &fibo_pattern_size, string fibo_patterns, string fibo_id ){
      string fibo_pat_arr_str[];
      fibo_pattern_size = StringSplit(fibo_patterns,StringGetCharacter(",",0),fibo_pat_arr_str);
      if(fibo_pattern_size < 0){ logMessage(LOG_ERROR,"",timeframes.DefaultValue(),"initCore",StringConcatenate("Invalid fibo_",fibo_id,"_patterns, value: ",fibo_patterns));}
      else if(fibo_pattern_size > 0){
         ArrayResize(fibo_pattern_values, fibo_pattern_size);
         ArrayInitialize(fibo_pattern_values, 0.0);
         ArrayResize(fibo_delta_values , fibo_pattern_size);
         ArrayInitialize(fibo_delta_values, 0.0);

         for(int i=0; i<fibo_pattern_size;i++){
            fibo_pattern_values[i] = StringToDouble(fibo_pat_arr_str[i]);
            fibo_delta_values[i][0] = fibo_pattern_values[i] * (1 - fibo_patterns_delta);
            fibo_delta_values[i][1] = fibo_pattern_values[i] * (1 + fibo_patterns_delta);
            //logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing fibo_",fibo_id,"_patterns, i: ",i,", value: ",fibo_pattern_values[i],", delta[0]: ",fibo_delta_values[i][0],", delta[1]: ", fibo_delta_values[i][1]));
         }
      }
   }
   //+------------------------------------------------------------------+
   void InitializeFiboWeakStrong(){

      string fibo_strong1_str[], fibo_strong2_str[], fibo_strong3_str[], fibo_strong4_str[];
      string fibo_weak1_str[], fibo_weak2_str[], fibo_weak3_str[], fibo_weak4_str[];
      fibo_strong_size[0] = StringSplit(fibo_strong1_patterns,StringGetCharacter(",",0),fibo_strong1_str);
      fibo_strong_size[1] = StringSplit(fibo_strong2_patterns,StringGetCharacter(",",0),fibo_strong2_str);
      fibo_strong_size[2] = StringSplit(fibo_strong3_patterns,StringGetCharacter(",",0),fibo_strong3_str);
      fibo_strong_size[3] = StringSplit(fibo_strong4_patterns,StringGetCharacter(",",0),fibo_strong4_str);

      fibo_weak_size[0] = StringSplit(fibo_weak1_patterns,StringGetCharacter(",",0),fibo_weak1_str);
      fibo_weak_size[1] = StringSplit(fibo_weak2_patterns,StringGetCharacter(",",0),fibo_weak2_str);
      fibo_weak_size[2] = StringSplit(fibo_weak3_patterns,StringGetCharacter(",",0),fibo_weak3_str);
      fibo_weak_size[3] = StringSplit(fibo_weak4_patterns,StringGetCharacter(",",0),fibo_weak4_str);

      if(fibo_strong_size[0] > 0){
         ArrayResize(fibo_strong1_values, fibo_strong_size[0]); ArrayInitialize(fibo_strong1_values, 0.0);
         ArrayResize(fibo_strong1_delta_values , fibo_strong_size[0]); ArrayInitialize(fibo_strong1_delta_values, 0.0);
         for(int i=0; i<fibo_strong_size[0];i++){
            fibo_strong1_values[i] = StringToDouble(fibo_strong1_str[i]);
            fibo_strong1_delta_values[i][0] = fibo_strong1_values[i] * (1 - fibo_patterns_delta);
            fibo_strong1_delta_values[i][1] = fibo_strong1_values[i] * (1 + fibo_patterns_delta);
            logMessage(LOG_INFO,"",timeframes.DefaultValue(),"initCore",StringConcatenate("Initializing fibo_strong1_patterns, i: ",i,", value: ",fibo_strong1_values[i],", delta[0]: ",fibo_strong1_delta_values[i][0],", delta[1]: ", fibo_strong1_delta_values[i][1]));
         }
      }
      if(fibo_strong_size[1] > 0){
         ArrayResize(fibo_strong2_values, fibo_strong_size[1]); ArrayInitialize(fibo_strong2_values, 0.0);
         ArrayResize(fibo_strong2_delta_values , fibo_strong_size[1]); ArrayInitialize(fibo_strong2_delta_values, 0.0);
         for(int i=0; i<fibo_strong_size[1];i++){
            fibo_strong2_values[i] = StringToDouble(fibo_strong2_str[i]);
            fibo_strong2_delta_values[i][0] = fibo_strong2_values[i] * (1 - fibo_patterns_delta);
            fibo_strong2_delta_values[i][1] = fibo_strong2_values[i] * (1 + fibo_patterns_delta);
            logMessage(LOG_INFO,"",timeframes.DefaultValue(),"initCore",StringConcatenate("Initializing fibo_strong2_patterns, i: ",i,", value: ",fibo_strong2_values[i],", delta[0]: ",fibo_strong2_delta_values[i][0],", delta[1]: ", fibo_strong2_delta_values[i][1]));
         }
      }
      if(fibo_strong_size[2] > 0){
         ArrayResize(fibo_strong3_values, fibo_strong_size[2]); ArrayInitialize(fibo_strong3_values, 0.0);
         ArrayResize(fibo_strong3_delta_values , fibo_strong_size[2]); ArrayInitialize(fibo_strong3_delta_values, 0.0);
         for(int i=0; i<fibo_strong_size[2];i++){
            fibo_strong3_values[i] = StringToDouble(fibo_strong3_str[i]);
            fibo_strong3_delta_values[i][0] = fibo_strong3_values[i] * (1 - fibo_patterns_delta);
            fibo_strong3_delta_values[i][1] = fibo_strong3_values[i] * (1 + fibo_patterns_delta);
            logMessage(LOG_INFO,"",timeframes.DefaultValue(),"initCore",StringConcatenate("Initializing fibo_strong3_patterns, i: ",i,", value: ",fibo_strong3_values[i],", delta[0]: ",fibo_strong3_delta_values[i][0],", delta[1]: ", fibo_strong3_delta_values[i][1]));
         }
      }
      if(fibo_strong_size[3] > 0){
         ArrayResize(fibo_strong4_values, fibo_strong_size[3]); ArrayInitialize(fibo_strong4_values, 0.0);
         ArrayResize(fibo_strong4_delta_values , fibo_strong_size[3]); ArrayInitialize(fibo_strong4_delta_values, 0.0);
         for(int i=0; i<fibo_strong_size[3];i++){
            fibo_strong4_values[i] = StringToDouble(fibo_strong4_str[i]);
            fibo_strong4_delta_values[i][0] = fibo_strong4_values[i] * (1 - fibo_patterns_delta);
            fibo_strong4_delta_values[i][1] = fibo_strong4_values[i] * (1 + fibo_patterns_delta);
            logMessage(LOG_INFO,"",timeframes.DefaultValue(),"initCore",StringConcatenate("Initializing fibo_strong4_patterns, i: ",i,", value: ",fibo_strong4_values[i],", delta[0]: ",fibo_strong4_delta_values[i][0],", delta[1]: ", fibo_strong4_delta_values[i][1]));
         }
      }

      if(fibo_weak_size[0] > 0){
         ArrayResize(fibo_weak1_values, fibo_weak_size[0]); ArrayInitialize(fibo_weak1_values, 0.0);
         ArrayResize(fibo_weak1_delta_values , fibo_weak_size[0]); ArrayInitialize(fibo_weak1_delta_values, 0.0);
         for(int i=0; i<fibo_weak_size[0];i++){
            fibo_weak1_values[i] = StringToDouble(fibo_weak1_str[i]);
            fibo_weak1_delta_values[i][0] = fibo_weak1_values[i] * (1 - fibo_patterns_delta);
            fibo_weak1_delta_values[i][1] = fibo_weak1_values[i] * (1 + fibo_patterns_delta);
            logMessage(LOG_INFO,"",timeframes.DefaultValue(),"initCore",StringConcatenate("Initializing fibo_weak1_patterns, i: ",i,", value: ",fibo_weak1_values[i],", delta[0]: ",fibo_weak1_delta_values[i][0],", delta[1]: ", fibo_weak1_delta_values[i][1]));
         }
      }
      if(fibo_weak_size[1] > 0){
         ArrayResize(fibo_weak2_values, fibo_weak_size[1]); ArrayInitialize(fibo_weak2_values, 0.0);
         ArrayResize(fibo_weak2_delta_values , fibo_weak_size[1]); ArrayInitialize(fibo_weak2_delta_values, 0.0);
         for(int i=0; i<fibo_weak_size[1];i++){
            fibo_weak2_values[i] = StringToDouble(fibo_weak2_str[i]);
            fibo_weak2_delta_values[i][0] = fibo_weak2_values[i] * (1 - fibo_patterns_delta);
            fibo_weak2_delta_values[i][1] = fibo_weak2_values[i] * (1 + fibo_patterns_delta);
            logMessage(LOG_INFO,"",timeframes.DefaultValue(),"initCore",StringConcatenate("Initializing fibo_weak2_patterns, i: ",i,", value: ",fibo_weak2_values[i],", delta[0]: ",fibo_weak2_delta_values[i][0],", delta[1]: ", fibo_weak2_delta_values[i][1]));
         }
      }
      if(fibo_weak_size[2] > 0){
         ArrayResize(fibo_weak3_values, fibo_weak_size[2]); ArrayInitialize(fibo_weak3_values, 0.0);
         ArrayResize(fibo_weak3_delta_values , fibo_weak_size[2]); ArrayInitialize(fibo_weak3_delta_values, 0.0);
         for(int i=0; i<fibo_weak_size[2];i++){
            fibo_weak3_values[i] = StringToDouble(fibo_weak3_str[i]);
            fibo_weak3_delta_values[i][0] = fibo_weak3_values[i] * (1 - fibo_patterns_delta);
            fibo_weak3_delta_values[i][1] = fibo_weak3_values[i] * (1 + fibo_patterns_delta);
            logMessage(LOG_INFO,"",timeframes.DefaultValue(),"initCore",StringConcatenate("Initializing fibo_weak3_patterns, i: ",i,", value: ",fibo_weak3_values[i],", delta[0]: ",fibo_weak3_delta_values[i][0],", delta[1]: ", fibo_weak3_delta_values[i][1]));
         }
      }
      if(fibo_weak_size[3] > 0){
         ArrayResize(fibo_weak4_values, fibo_weak_size[3]); ArrayInitialize(fibo_weak4_values, 0.0);
         ArrayResize(fibo_weak4_delta_values , fibo_weak_size[3]); ArrayInitialize(fibo_weak4_delta_values, 0.0);
         for(int i=0; i<fibo_weak_size[3];i++){
            fibo_weak4_values[i] = StringToDouble(fibo_weak4_str[i]);
            fibo_weak4_delta_values[i][0] = fibo_weak4_values[i] * (1 - fibo_patterns_delta);
            fibo_weak4_delta_values[i][1] = fibo_weak4_values[i] * (1 + fibo_patterns_delta);
            logMessage(LOG_INFO,"",timeframes.DefaultValue(),"initCore",StringConcatenate("Initializing fibo_weak4_patterns, i: ",i,", value: ",fibo_weak4_values[i],", delta[0]: ",fibo_weak4_delta_values[i][0],", delta[1]: ", fibo_weak4_delta_values[i][1]));
         }
      }
   }
   //+------------------------------------------------------------------+
   void updateHarmonicTradeSignals(){

      //sellSignalByHarmonicSetup[core.getSymbolPos()][iSetup] = buySignalByHarmonicSetup[iSymbol][iSetup] = false;

   }
   //+------------------------------------------------------------------+
   bool getBuySignalByZigZagSetup(int iSymbol, int iSetup)
   {
      if( !useZigZag || (
          (!use_fiboMinMax || sellSignalByFiboMinMaxSetup[iSymbol][iSetup]) &&
          (!use_fiboPatterns || sellSignalByFiboPatternSetup[iSymbol][iSetup]) &&
          (!use_zigzag_size || sellSignalByZzSizeSetup[iSymbol][iSetup]) &&
          (!use_zigzag_angle || sellSignalByZzAngleSetup[iSymbol][iSetup])
        )){
         return true;
      }
      return false;
   }
   //+------------------------------------------------------------------+
   bool getSellSignalByZigZagSetup(int iSymbol, int iSetup)
   {

      if( !useZigZag || (
          (!use_fiboMinMax || buySignalByFiboMinMaxSetup[iSymbol][iSetup]) &&
          (!use_fiboPatterns || buySignalByFiboPatternSetup[iSymbol][iSetup]) &&
          (!use_zigzag_size || buySignalByZzSizeSetup[iSymbol][iSetup]) &&
          (!use_zigzag_angle || buySignalByZzAngleSetup[iSymbol][iSetup])
        )){
            return true;
      }
      return false;
   }
   //+------------------------------------------------------------------+
   void updateAllZigZag(bool resetLines = false)
   {
      for(int iSymbol=0; iSymbol < core.getSymbolCount(); iSymbol++)
      {
         updateZigZagBySymbol(iSymbol, resetLines);
      }
   }
   void updateZigZagBySymbol(int iSymbol, bool resetLines = false)
   {
      for(int iSetup=0; iSetup < TF_COUNT; iSetup++)
      {
         updateZigZagBySetup(iSymbol, iSetup, resetLines);
      }
   }
   void updateZigZagBySetup(int iSymbol, int iSetup, bool resetLines = false)
   {
      if(!timeframes.InUse(iSetup)) return;
      
      settings[iSymbol][iSetup].updateSettings();
      if(resetLines)
         zzCtrl[iSymbol][iSetup].reinitLines();
      else
         zzCtrl[iSymbol][iSetup].updateZigZag();


      if(use_zigzag_size){
         sellSignalByZzSizeSetup[iSymbol][iSetup] = buySignalByZzSizeSetup[iSymbol][iSetup] = false;
         if( (zz_CD_size_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.size <= zz_CD_size_MAX) &&
             (zz_CD_size_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.size >= zz_CD_size_MIN) &&
             (zz_BC_size_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.size <= zz_BC_size_MAX) &&
             (zz_BC_size_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.size >= zz_BC_size_MIN) &&
             (zz_AB_size_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.size <= zz_AB_size_MAX) &&
             (zz_AB_size_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.size >= zz_AB_size_MIN) &&
             (zz_XA_size_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.size <= zz_XA_size_MAX) &&
             (zz_XA_size_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.size >= zz_XA_size_MIN)
            ){
               if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH)
                  sellSignalByZzSizeSetup[iSymbol][iSetup] = true;
               else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW)
                  buySignalByZzSizeSetup[iSymbol][iSetup] = true;
         }
      }
      if(use_zigzag_angle){
         sellSignalByZzAngleSetup[iSymbol][iSetup] = buySignalByZzAngleSetup[iSymbol][iSetup] = false;
         if( (zz_CD_angle_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle <= zz_CD_angle_MAX) &&
             (zz_CD_angle_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle >= zz_CD_angle_MIN) &&
             (zz_BC_angle_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle <= zz_BC_angle_MAX) &&
             (zz_BC_angle_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle >= zz_BC_angle_MIN) &&
             (zz_AB_angle_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle <= zz_AB_angle_MAX) &&
             (zz_AB_angle_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle >= zz_AB_angle_MIN) &&
             (zz_XA_angle_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle <= zz_XA_angle_MAX) &&
             (zz_XA_angle_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle >= zz_XA_angle_MIN)
            ){
               if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH)
                  sellSignalByZzAngleSetup[iSymbol][iSetup] = true;
               else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW)
                  buySignalByZzAngleSetup[iSymbol][iSetup] = true;
         }
      }
      if(use_fiboMinMax){
        sellSignalByFiboMinMaxSetup[iSymbol][iSetup] = buySignalByFiboMinMaxSetup[iSymbol][iSetup] = false;
        if( (fibo_BD_MAX == 0 || zzCtrl[iSymbol][iSetup].fiboBD <= fibo_BD_MAX) &&
            (fibo_BD_MIN == 0 || zzCtrl[iSymbol][iSetup].fiboBD >= fibo_BD_MIN) &&
            (fibo_AC_MAX == 0 || zzCtrl[iSymbol][iSetup].fiboAC <= fibo_AC_MAX) &&
            (fibo_AC_MIN == 0 || zzCtrl[iSymbol][iSetup].fiboAC >= fibo_AC_MIN) &&
            (fibo_XB_MAX == 0 || zzCtrl[iSymbol][iSetup].fiboXB <= fibo_XB_MAX) &&
            (fibo_XB_MIN == 0 || zzCtrl[iSymbol][iSetup].fiboXB >= fibo_XB_MIN) &&
            (fibo_XD_MAX == 0 || zzCtrl[iSymbol][iSetup].fiboXD <= fibo_XD_MAX) &&
            (fibo_XD_MIN == 0 || zzCtrl[iSymbol][iSetup].fiboXD >= fibo_XD_MIN)
           ){
              if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH)
                 sellSignalByFiboMinMaxSetup[iSymbol][iSetup] = true;
              else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW)
                 buySignalByFiboMinMaxSetup[iSymbol][iSetup] = true;
        }
      }
      if(use_fiboPatterns){
        sellSignalByFiboPatternSetup[iSymbol][iSetup] = buySignalByFiboPatternSetup[iSymbol][iSetup] = false;
        bool  fibo_matched = true, trendFiboMatched = true;
        double fiboValue = 0;
        ZZ_FIBO_PATTERN fibo_pattern = BD_PATTERN;

        if(fibo_pattern_main == BD_PATTERN){
           fiboValue = zzCtrl[iSymbol][iSetup].fiboBD;
           if(update_currentFiboBD || !allTicks) fiboValue = zzCtrl[iSymbol][iSetup].fiboCurrentBD;
           else fiboValue = zzCtrl[iSymbol][iSetup].fiboBD;
        }
        else if(fibo_pattern_main == AC_PATTERN){
           fiboValue = zzCtrl[iSymbol][iSetup].fiboAC;
           fibo_pattern = AC_PATTERN;
        }
        else if(fibo_pattern_main == XB_PATTERN){
           fiboValue = zzCtrl[iSymbol][iSetup].fiboXB;
           fibo_pattern = XB_PATTERN;
        }
        else if(fibo_pattern_main == XD_PATTERN){
           fiboValue = zzCtrl[iSymbol][iSetup].fiboXD;
           fibo_pattern = XD_PATTERN;
        }
        else if(fibo_pattern_main == AD_PATTERN){
           fiboValue = zzCtrl[iSymbol][iSetup].fiboAD;
           fibo_pattern = AD_PATTERN;
        }

        if(fibo_matched && trendFiboMatched && fibo_BD_pattern_size > 0 ){
           fibo_matched = matchFiboPattern(iSymbol, iSetup, fibo_BD_pattern_values, fibo_BD_delta_values, fibo_BD_pattern_size, zzCtrl[iSymbol][iSetup].fiboBD, (fibo_pattern_main == BD_PATTERN));
        }
        if(fibo_matched && trendFiboMatched && fibo_XD_pattern_size > 0){
           fibo_matched = matchFiboPattern(iSymbol, iSetup, fibo_XD_pattern_values, fibo_XD_delta_values, fibo_XD_pattern_size, zzCtrl[iSymbol][iSetup].fiboXD, (fibo_pattern_main == XD_PATTERN));
        }
        if(fibo_matched && trendFiboMatched && fibo_XB_pattern_size > 0){
           fibo_matched = matchFiboPattern(iSymbol, iSetup, fibo_XB_pattern_values, fibo_XB_delta_values, fibo_XB_pattern_size, zzCtrl[iSymbol][iSetup].fiboXB, (fibo_pattern_main == XB_PATTERN));
        }
        if(fibo_matched && trendFiboMatched && fibo_AC_pattern_size > 0){
           fibo_matched = matchFiboPattern(iSymbol, iSetup, fibo_AC_pattern_values, fibo_AC_delta_values, fibo_AC_pattern_size, zzCtrl[iSymbol][iSetup].fiboAC, (fibo_pattern_main == AC_PATTERN));
        }
        if(fibo_matched && trendFiboMatched && fibo_AD_pattern_size > 0){
           fibo_matched = matchFiboPattern(iSymbol, iSetup, fibo_AD_pattern_values, fibo_AD_delta_values, fibo_AD_pattern_size, zzCtrl[iSymbol][iSetup].fiboAD, (fibo_pattern_main == AD_PATTERN));
        }

        if(fibo_matched && trendFiboMatched)
        {
           if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH &&
              !(fibo_lastTradeType[iSymbol][iSetup] == OP_SELL && fibo_lastTradeFibo[iSymbol][iSetup] >= fibo_lastMatchFibo[iSymbol][iSetup])){
              sellSignalByFiboPatternSetup[iSymbol][iSetup] = true;
              //Print("sellSignalByFiboPatternSetup[iSymbol][iSetup] = true;");
           }
           else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW &&
              !(fibo_lastTradeType[iSymbol][iSetup] == OP_BUY && fibo_lastTradeFibo[iSymbol][iSetup] >= fibo_lastMatchFibo[iSymbol][iSetup])){
              buySignalByFiboPatternSetup[iSymbol][iSetup] = true;
              //Print("buySignalByFiboPatternSetup[iSymbol][iSetup] = true;");
           }
        }
      }


   }
   //+------------------------------------------------------------------+
   string updateZupMessages(int iSym){
      string msgZup = "";
      for(int iSetup=0; iSetup<TF_COUNT; iSetup++){
         if(timeframes.InUse(iSetup)){
            string avgVB_msg = "", fiboBalance_msg = "", setupBalance_msg = "";

            msgZup += StringConcatenate(core.getSymbol(iSym), "/Setup",iSetup,"(",setupValue[iSetup][0],",",setupValue[iSetup][1],",",setupValue[iSetup][2],") ");
            msgZup += avgVB_msg + fiboBalance_msg + setupBalance_msg;
            if(zzCtrl[iSym][iSetup] != NULL){
               if(use_zigzag_size){
                  msgZup += "ZzSize: ";
                  if(zz_CD_size_MIN > 0) msgZup += StringConcatenate("CdMin(",zz_CD_size_MIN,",",zzCtrl[iSym][iSetup].lineCD.size,") ");
                  if(zz_CD_size_MAX > 0) msgZup += StringConcatenate("CdMax(",zz_CD_size_MAX,",",zzCtrl[iSym][iSetup].lineCD.size,") ");
                  if(zz_BC_size_MIN > 0) msgZup += StringConcatenate("BcMin(",zz_BC_size_MIN,",",zzCtrl[iSym][iSetup].lineBC.size,") ");
                  if(zz_BC_size_MAX > 0) msgZup += StringConcatenate("BcMax(",zz_BC_size_MAX,",",zzCtrl[iSym][iSetup].lineBC.size,") ");
                  if(zz_AB_size_MIN > 0) msgZup += StringConcatenate("AbMin(",zz_AB_size_MIN,",",zzCtrl[iSym][iSetup].lineAB.size,") ");
                  if(zz_AB_size_MAX > 0) msgZup += StringConcatenate("AbMax(",zz_AB_size_MAX,",",zzCtrl[iSym][iSetup].lineAB.size,") ");
                  if(zz_XA_size_MIN > 0) msgZup += StringConcatenate("XaMin(",zz_XA_size_MIN,",",zzCtrl[iSym][iSetup].lineXA.size,") ");
                  if(zz_XA_size_MAX > 0) msgZup += StringConcatenate("XaMax(",zz_XA_size_MAX,",",zzCtrl[iSym][iSetup].lineXA.size,") ");
               }
               if(use_zigzag_angle){
                  msgZup += ", ZzAngle: ";
                  if(zz_CD_angle_MIN > 0) msgZup += StringConcatenate("CdMin(",zz_CD_angle_MIN,",",zzCtrl[iSym][iSetup].lineCD.angle,") ");
                  if(zz_CD_angle_MAX > 0) msgZup += StringConcatenate("CdMax(",zz_CD_angle_MAX,",",zzCtrl[iSym][iSetup].lineCD.angle,") ");
                  if(zz_BC_angle_MIN > 0) msgZup += StringConcatenate("BcMin(",zz_BC_angle_MIN,",",zzCtrl[iSym][iSetup].lineBC.angle,") ");
                  if(zz_BC_angle_MAX > 0) msgZup += StringConcatenate("BcMax(",zz_BC_angle_MAX,",",zzCtrl[iSym][iSetup].lineBC.angle,") ");
                  if(zz_AB_angle_MIN > 0) msgZup += StringConcatenate("AbMin(",zz_AB_angle_MIN,",",zzCtrl[iSym][iSetup].lineAB.angle,") ");
                  if(zz_AB_angle_MAX > 0) msgZup += StringConcatenate("AbMax(",zz_AB_angle_MAX,",",zzCtrl[iSym][iSetup].lineAB.angle,") ");
                  if(zz_XA_angle_MIN > 0) msgZup += StringConcatenate("XaMin(",zz_XA_angle_MIN,",",zzCtrl[iSym][iSetup].lineXA.angle,") ");
                  if(zz_XA_angle_MAX > 0) msgZup += StringConcatenate("XaMax(",zz_XA_angle_MAX,",",zzCtrl[iSym][iSetup].lineXA.angle,") ");
               }
               if(use_fiboMinMax){
                  msgZup += ", FiboMM: ";
                  if(fibo_BD_MIN > 0) msgZup += StringConcatenate("BdMin(",fibo_BD_MIN,",",zzCtrl[iSym][iSetup].fiboBD,") ");
                  if(fibo_BD_MAX > 0) msgZup += StringConcatenate("BdMax(",fibo_BD_MAX,",",zzCtrl[iSym][iSetup].fiboBD,") ");
                  if(fibo_AC_MIN > 0) msgZup += StringConcatenate("AcMin(",fibo_AC_MIN,",",zzCtrl[iSym][iSetup].fiboAC,") ");
                  if(fibo_AC_MAX > 0) msgZup += StringConcatenate("AcMax(",fibo_AC_MAX,",",zzCtrl[iSym][iSetup].fiboAC,") ");
                  if(fibo_XB_MIN > 0) msgZup += StringConcatenate("XbMin(",fibo_XB_MIN,",",zzCtrl[iSym][iSetup].fiboXB,") ");
                  if(fibo_XB_MAX > 0) msgZup += StringConcatenate("XbMax(",fibo_XB_MAX,",",zzCtrl[iSym][iSetup].fiboXD,") ");
                  if(fibo_XD_MIN > 0) msgZup += StringConcatenate("XdMin(",fibo_XD_MIN,",",zzCtrl[iSym][iSetup].fiboXD,") ");
                  if(fibo_XD_MAX > 0) msgZup += StringConcatenate("XdMax(",fibo_XD_MAX,",",zzCtrl[iSym][iSetup].fiboXD,") ");
               }
               if(use_fiboPatterns){
                  double fiboBD = 0;
                  if(update_currentFiboBD) fiboBD = zzCtrl[iSym][iSetup].fiboCurrentBD;
                  else fiboBD = zzCtrl[iSym][iSetup].fiboBD;
                  msgZup += ", FiboPat: ";
                  if(fibo_BD_pattern_size > 0) msgZup += StringConcatenate("BD(",fibo_BD_patterns,")(",fiboBD,") ");
                  if(fibo_AC_pattern_size > 0) msgZup += StringConcatenate("AC(",fibo_AC_patterns,")(",zzCtrl[iSym][iSetup].fiboAC,") ");
                  if(fibo_XB_pattern_size > 0) msgZup += StringConcatenate("XB(",fibo_XB_patterns,")(",zzCtrl[iSym][iSetup].fiboXB,") ");
                  if(fibo_XD_pattern_size > 0) msgZup += StringConcatenate("XD(",fibo_XD_patterns,")(",zzCtrl[iSym][iSetup].fiboXD,") ");
               }
            }
            msgZup += "\n";
         }
      }
      return msgZup;
   }

//+------------------------------------------------------------------+
//| END ZigZagFiboPattern Class                                      |
//+------------------------------------------------------------------+
};
