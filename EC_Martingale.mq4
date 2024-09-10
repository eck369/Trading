//+------------------------------------------------------------------+
//|                                                    AutoTrade.mq4 |
//|                                                    STGW Solution |
//|                                                                  |
//+------------------------------------------------------------------+
#property version   "1.0"

#include <STGW_Fw\Manager\RiskMgr.mqh>
#include "EC_Martingale.mqh"

/*  Child class of CStrategyBase instantiation */
C_FCS_IBL_M g_Strategy;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{ 

	g_AccMgr.UpdateAcc();
   g_TicketMgr.Init(&g_Strategy, &g_StopLossMgr, &g_TakeProfitMgr);
   g_RiskMgr.Init();
          
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES); 
   ChartSetInteger(0, CHART_SHOW_GRID, false); 
   ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR, true);
   ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, true);
   
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   switch(UninitializeReason())
     {
      case REASON_ACCOUNT:
      break;
      
      case REASON_CHARTCHANGE:
      break;
      
      case REASON_CHARTCLOSE:
      break;
      
      case REASON_PARAMETERS:
      break;
      
      case REASON_RECOMPILE:
      break;
      
      case REASON_REMOVE:
         g_TicketMgr.DeleteAllTickets();
      break;
      
      case REASON_TEMPLATE:
      break;
      
      default:
      break;
     }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{  
   if(TRADE_ENABLE != g_RiskMgr.IsEnabled())
   {  
      return;
   }
   
   if(TRADE_ENABLE == g_RiskMgr.RiskCheck())
   {
   	g_AccMgr.UpdateAcc();
      g_TicketMgr.UpdateTicket();
      g_DayMgr.CheckDay();
      g_NewsMgr.CheckNews();
      g_SessMgr.UpdateSession();
      g_Strategy.AutoTrade();
   //   g_AccMgr.UpdateBalance();
   }
}

//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
{
}
//+------------------------------------------------------------------+
