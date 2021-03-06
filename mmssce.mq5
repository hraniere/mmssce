//+------------------------------------------------------------------+
//|                                                       mmssce.mq5 |
//|                                                    Petrus Bastos |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red

input int MAPeriod= 15;
input int MAShift = 0;

double ExtLineBuffer[];

void OnInit(){
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_SHIFT,MAShift);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MAPeriod);   
}

int OnCalculate (const int rates_total,      // tamanho da série de preços de entrada series 
                 const int prev_calculated,  // barras tratadas na chamada anterior 
                 const datetime& time[],     // Hora 
                 const double& open[],       // Open (abertura) 
                 const double& high[],       // High (máximo) 
                 const double& low[],        // Low (mínimo) 
                 const double& close[],      // Close (fechamento) 
                 const long& tick_volume[],  // Volume de Tick 
                 const long& volume[],       // Volume Real 
                 const int& spread[]){         // Spread 
    
    // Sai se não tem dados suficientes para calcular a média móvel...
   if(rates_total<MAPeriod-1){
      return(0);
   }
         
   // Validar que o gráfico está sendo apresentado em 15 minutos...
   if (Period() != PERIOD_M15) {
      Print("Este indicador de média móvel só deve funcionar para o gráfico de 15 minutos!"); 
      return (0);
   }

   // Prepara algumas variáveis que serão utilizadas ao longo da execução...   
   int first,bar,iii,barraExtra;
   double Sum,SMA;

   if(prev_calculated==0){
      first=MAPeriod-1;
   } else {
      first=prev_calculated-1;  
   }
      
   for(bar=first;bar<rates_total;bar++){

      Sum=0.0;
      barraExtra = 0;
      
      for(iii=0;iii<MAPeriod;iii++){
         if (open[bar-iii]==close[bar-iii] && open[bar-iii] == low[bar-iii] && open[bar-iii] == high[bar-iii]){ // incrementar aqui para verificar se o proximo candle tem data diferente...
            barraExtra++;
         }
      }
         
      for(iii=0;iii<MAPeriod+barraExtra;iii++){
         
         // Este for é para proteger a média quando os dados são incoerentes...
         if (bar - iii < 0){
            break;
         }
         
         if (open[bar-iii]==close[bar-iii] && open[bar-iii] == low[bar-iii] && open[bar-iii] == high[bar-iii]){ // incrementar aqui para verificar se o proximo candle tem data diferente...
            continue;
         } else if (open[bar-iii+1]==close[bar-iii+1] && open[bar-iii+1] == low[bar-iii+1] && open[bar-iii+1] == high[bar-iii+1]){
            Sum+=close[bar-iii+1];
         } else {
            Sum+=close[bar-iii];          
         }
      }
         
      SMA=Sum/MAPeriod;
         
      if (open[bar]==close[bar] && open[bar] == low[bar] && open[bar] == high[bar]){ // incrementar aqui para verificar se o proximo candle tem data diferente...
         ExtLineBuffer[bar]=ExtLineBuffer[bar-1];         
      } else {
         ExtLineBuffer[bar]=SMA;         
      }
         
   }
   
   return(rates_total);
   
}