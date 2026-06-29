//+------------------------------------------------------------------+
//|                                          PitchforkController.mqh |
//|                                            Rodrigo Maia Escorsim |
//|                                       rodrigo.escorsim@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Maia Escorsim"
#property link      "rodrigo.escorsim@gmail.com"
#property strict


#include <modulos/Pitchfork2.mqh>

//+------------------------------------------------------------------+
//| PitchforkController Class                                        |
//+------------------------------------------------------------------+
class PitchforkController{
private:
   bool updatePointD;
   bool show_pitchfork_ABC, show_pitchfork_BCD;
public:   
   Pitchfork *pitchforkXAB, *pitchforkABC, *pitchforkBCD;

   GeometrySettings* settings;
   ZigzagController *zzController;
   PitchForkChartSettings *chart_ap_settings1;
   PitchForkChartSettings *chart_ap_settings2;
    
   //+------------------------------------------------------------------+
   //| Constructor and Destructor                                       |
   //+------------------------------------------------------------------+
   PitchforkController(){
   }
   ~PitchforkController(){
      if(pitchforkXAB != NULL) delete(pitchforkXAB);
      if(pitchforkABC != NULL) delete(pitchforkABC);
      if(pitchforkBCD != NULL) delete(pitchforkBCD);
   }
   //+------------------------------------------------------------------+
   //| INIT Pitchfork                                                   |
   //+------------------------------------------------------------------+
   void initPitchfork(ZigzagController *_zzController){
      zzController = _zzController;
      settings = zzController.settings;
      
      if(settings.useBlackColors){ chart_ap_settings1 = &chartAP_Black1; chart_ap_settings2 = &chartAP_Black2; } 
      else{ chart_ap_settings1 = &chartAP_White1; chart_ap_settings2 = &chartAP_White2; } 
            
      if(settings.type_execution == EXECUTION_DEBUG) {   show_pitchfork_ABC = true;  show_pitchfork_BCD = true;   }
      if(settings.type_execution == EXECUTION_EA)    {   show_pitchfork_ABC = false; show_pitchfork_BCD = false;  }
      
      pitchforkABC = pitchforkXAB = pitchforkBCD = NULL;
      if(settings.useApTrigger){
         pitchforkABC = new Pitchfork("ABC", zzController.lineAB, zzController.lineBC, settings, chart_ap_settings2, false, false, settings.useApTrigger, show_pitchfork_ABC);
         pitchforkXAB = new Pitchfork("XAB", zzController.lineXA, zzController.lineAB, settings, chart_ap_settings2, false, false, settings.useApTrigger, show_pitchfork_ABC);
      }
      if(settings.useApMedian){
         pitchforkBCD = new Pitchfork("BCD", zzController.lineBC, zzController.lineCD, settings, chart_ap_settings1, settings.useApMedian, settings.useApTynes, settings.useApTrigger, show_pitchfork_BCD);
      }
      if(pitchforkXAB != NULL) pitchforkXAB.updateValues();
      if(pitchforkABC != NULL) pitchforkABC.updateValues();
      if(pitchforkBCD != NULL) pitchforkBCD.updateValues(); 
      updatePointD = false;
   }
   //+------------------------------------------------------------------+
   //| UPDATE Pitchfork                                                 |
   //+------------------------------------------------------------------+   
   void updatePitchfork(){
   
      if(settings.newLine){
         if(pitchforkXAB != NULL) pitchforkXAB.setLines(zzController.lineXA, zzController.lineAB);
         if(pitchforkABC != NULL) pitchforkABC.setLines(zzController.lineAB, zzController.lineBC);
         if(pitchforkBCD != NULL) pitchforkBCD.setLines(zzController.lineBC, zzController.lineCD);
      }
      if(settings.newPeak || settings.newBar || settings.updateAllTick || settings.newLine){
         if(pitchforkXAB != NULL) pitchforkXAB.updateValues(); 
         if(pitchforkABC != NULL) pitchforkABC.updateValues(); 
         if(pitchforkBCD != NULL) pitchforkBCD.updateValues(); 
         
         /*if(show_pitchfork_BCD){
         
            if(settings.newPeak){
            
               if(!updatePointD && pitchforkBCD.isActive()){ 
                  pitchforkBCD.delete_Pitchfork_Objects();
                  updatePointD = true;
               }
            }
            if(settings.newBar){
               if(updatePointD){
                  if(show_pitchfork_BCD){
                     pitchforkBCD.create_Pitchfork_Objects();
                  }
                  updatePointD = false;
               }
               else{
                  if(pitchforkBCD.isActive()){
                     pitchforkBCD.move_Pitchfork_Objects();
                  }
                  //else{
                  //   pitchforkBCD.create_Pitchfork_Objects();
                  //}
               }
            }
         }*/
      }
      
   }
};