//+------------------------------------------------------------------+
//| Class CTrailing                                                  |
//| Appointment: Base Class for Trailing.                            |
//+------------------------------------------------------------------+
#include <STGW_Fw\Configuration.mqh>
#include <STGW_Fw\Manager\AccountMgr.mqh>
#include <STGW_Fw\Manager\TicketMgr.mqh>
#include <STGW_Fw\Trade.mqh>
#include <STGW_Fw\Manager\TakeProfitMgr.mqh>
#include <STGW_Fw\Manager\StopLossMgr.mqh>
#include <STGW_Fw\Manager\StopLossMgr.mqh>
#include <STGW_Fw\Manager\SessionMgr.mqh>
#include <STGW_Fw\Manager\DayMgr.mqh>
#include <STGW_Fw\Manager\NewsMgr.mqh>

input string InpComment = NULL;
input bool   InpEnableAutoLotFlag  = false;
input double InpAutoLotValue       = 1000;
input double InpLot                = 0.01;
input double InpMaxLostPct         = 100;
input double InpMaxLostAmountUSD   = 30;
input double InpFirstTpPips        = 20;
input double InpWhenToBePips       = 0;
input double InpPointLockIn        = 0;
e_TRAIL_TYPE InpTrailType          = FOLLOW_TRAIL;
double InpTrailStepPoint           = 0;
input uint InpWhenToTrailPips      = 20;
input uint InpTrailPips            = 10;
input uint InpTotalWhenToTrailPips = 10;
input uint InpTotalTrailPips       = 5;
input double InpTotalTpPips        = 50;
input int InpFridayBeHour  = 24;
input double InpTotalBePips = 1000;
input int InpMondayStartHour = 0;
input int InpBeLevel    = 6;
input int InpPips = 0;
input int InpStartMinutes = 0;
input bool InpBuyOption = true;
input bool InpSellOption = true;
input int    MovingPeriod  =12;
input int    MovingShift   =6;

input int Inp1DistancePips = 20;
input int Inp2DistancePips = 20;
input int Inp3DistancePips = 20;
input int Inp4DistancePips = 20;
input int Inp5DistancePips = 20;
input int Inp6DistancePips = 20;
input int Inp7DistancePips = 20;
input int Inp8DistancePips = 20;
input int Inp9DistancePips = 20;
input int Inp10DistancePips = 20;
input int Inp11DistancePips = 20;
input int Inp12DistancePips = 20;
input int Inp13DistancePips = 20;
input int Inp14DistancePips = 20;

input int InpLevelMultiplier1 = 1;
input int InpLevelMultiplier2 = 2;
input int InpLevelMultiplier3 = 3;
input int InpLevelMultiplier4 = 4;
input int InpLevelMultiplier5 = 5;
input int InpLevelMultiplier6 = 6;
input int InpLevelMultiplier7 = 7;
input int InpLevelMultiplier8 = 8;
input int InpLevelMultiplier9 = 9;
input int InpLevelMultiplier10 = 10;
input int InpLevelMultiplier11 = 11;
input int InpLevelMultiplier12 = 12;
input int InpLevelMultiplier13 = 13;
input int InpLevelMultiplier14 = 14;
   
      
struct MartingaleLevel_s
{
   double   Multiplier;
   double   DistancePips;
};
struct OrderMode_s
{
   double   Opnl;
   double   lots;
   int      trades;
   double   FloatingCount;
   datetime OrderTime; 
};

OrderMode_s Buy;
OrderMode_s Sell;
MartingaleLevel_s MartingaleLevel[14];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_FCS_IBL_M : public CStrategyBase
  {   
protected:
	int					m_ticket;
public:
                     C_FCS_IBL_M(void);
                    ~C_FCS_IBL_M(void);
   bool              AutoTrade(void);
   void              GetOrderdetail(void);
   void              SetLabel(string name1, string text, color clr, int xdistance, int ydistance, int corner=1, int fontsize=15);

   int               Ticket;
   int               BuyCount;
   int               SellCount;
   int               FirstBuyTicket;
   int               FirstSellTicket;
   bool              BuyOptionflag;
   bool              SellOptionflag;  
   bool              BuyStartTrailing;
   bool              SellStartTrailing;   
   string            obj_prefix;
   double            ma;
   double            Pips;
   double            InitialBalance;
   double            HighestEquity;
   double            OrderLotSize;
   double            BuyOrderLotSize;
   double            SellOrderLotSize;
   double            trades;
   double            lots;
   double            Opnl;
   double            Tp; 
   double            BuyTrailingPnL;  
   double            SellTrailingPnL;    
   double            SaveNearestBuyPrice;
   double            SaveNearestSellPrice;
   bool              BuyResetFlag;
   bool              SellResetFlag;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_FCS_IBL_M::C_FCS_IBL_M(void)
{  
   if(InpPips)
   {
      Pips = InpPips;   
   }
   else
   {
      Pips = g_AccMgr.CalcPip(Symbol());
   }
   InitialBalance = AccountBalance();
   Tp = 0;
   BuyOptionflag  = InpBuyOption;
   SellOptionflag = InpSellOption;
   BuyStartTrailing = false;
   SellStartTrailing = false;
   BuyTrailingPnL = InpTotalWhenToTrailPips*OrderLotSize*10*MarketInfo(Symbol(),MODE_TICKVALUE);
   SellTrailingPnL = InpTotalWhenToTrailPips*OrderLotSize*10*MarketInfo(Symbol(),MODE_TICKVALUE);
         
   MartingaleLevel[0].Multiplier = InpLevelMultiplier1;
   MartingaleLevel[1].Multiplier = InpLevelMultiplier2;
   MartingaleLevel[2].Multiplier = InpLevelMultiplier3;
   MartingaleLevel[3].Multiplier = InpLevelMultiplier4;
   MartingaleLevel[4].Multiplier = InpLevelMultiplier5;
   MartingaleLevel[5].Multiplier = InpLevelMultiplier6;
   MartingaleLevel[6].Multiplier = InpLevelMultiplier7;
   MartingaleLevel[7].Multiplier = InpLevelMultiplier8;
   MartingaleLevel[8].Multiplier = InpLevelMultiplier9;
   MartingaleLevel[9].Multiplier = InpLevelMultiplier10;
   MartingaleLevel[10].Multiplier = InpLevelMultiplier11;
   MartingaleLevel[11].Multiplier = InpLevelMultiplier12;
   MartingaleLevel[12].Multiplier = InpLevelMultiplier13;
   MartingaleLevel[13].Multiplier = InpLevelMultiplier14;

   MartingaleLevel[0].DistancePips = Inp1DistancePips*Pips;
   MartingaleLevel[1].DistancePips = Inp2DistancePips*Pips;
   MartingaleLevel[2].DistancePips = Inp3DistancePips*Pips;
   MartingaleLevel[3].DistancePips = Inp4DistancePips*Pips;
   MartingaleLevel[4].DistancePips = Inp5DistancePips*Pips;
   MartingaleLevel[5].DistancePips = Inp6DistancePips*Pips;
   MartingaleLevel[6].DistancePips = Inp7DistancePips*Pips;
   MartingaleLevel[7].DistancePips = Inp8DistancePips*Pips;
   MartingaleLevel[8].DistancePips = Inp9DistancePips*Pips;
   MartingaleLevel[9].DistancePips = Inp10DistancePips*Pips;
   MartingaleLevel[10].DistancePips = Inp11DistancePips*Pips;
   MartingaleLevel[11].DistancePips = Inp12DistancePips*Pips;
   MartingaleLevel[12].DistancePips = Inp13DistancePips*Pips;
   MartingaleLevel[13].DistancePips = Inp14DistancePips*Pips;
}
C_FCS_IBL_M::~C_FCS_IBL_M(void)
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool C_FCS_IBL_M::AutoTrade(void)
{

   if(Year()>=2026)
   {
      Alert("code expired");
      return false;
   }
     
   s_IntTp tp;
   ZeroMemory(tp);  
   s_TrailStop Trail;
   ZeroMemory(Trail);

   ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
   GetOrderdetail();

   if(SaveNearestBuyPrice - Ask >= MartingaleLevel[Buy.trades].DistancePips && BuyOptionflag
   && g_TicketMgr.TotalTicketByCmd(OP_BUY,Symbol(),InpEa_MagicNo) > 0
   )
   {
      BuyOrderLotSize = OrderLotSize*MartingaleLevel[Buy.trades].Multiplier;

      Ticket = g_Trade.Buy(Symbol(),BuyOrderLotSize,0,0,0,3,InpEa_MagicNo,0,InpComment,clrBlue);
      if(Ticket > 0)
      {      
         BuyStartTrailing = false;                 
      } 
   }
   if(Bid - SaveNearestSellPrice  >= MartingaleLevel[Sell.trades].DistancePips && SellOptionflag
   && g_TicketMgr.TotalTicketByCmd(OP_SELL,Symbol(),InpEa_MagicNo) > 0
   )
   {
      SellOrderLotSize = OrderLotSize*MartingaleLevel[Sell.trades].Multiplier;

      Ticket = g_Trade.Sell(Symbol(),SellOrderLotSize,0,0,0,3,InpEa_MagicNo,0,InpComment,clrBlue);
      if(Ticket > 0)
      { 
         SellStartTrailing = false; 
      }  
   }
         
   if(g_TicketMgr.TotalTicketByCmd(OP_BUY,Symbol(),InpEa_MagicNo) == 0 && BuyOptionflag
   && (Bid>ma) && Minute() > InpStartMinutes 
   && (DayOfWeek() != 5 || (DayOfWeek() == 5 && Hour() < InpFridayBeHour))
   && (DayOfWeek() != 1 || (DayOfWeek() == 1 && Hour() >= InpMondayStartHour))
   )
   {
      if(InpFirstTpPips > 0)
      {
         Tp = InpFirstTpPips*Pips;
      }
      Ticket = g_Trade.Buy(Symbol(),OrderLotSize,0,0,0,3,InpEa_MagicNo,0,InpComment,clrBlue);
      if(Ticket > 0)
      {      
         tp.val[0]      = Tp;                         
         tp.lot[0]      = OrderLotSize;  
   
         g_TakeProfitMgr.SetIntTakeProfitPt(Ticket,OrderLotSize,tp);
         
         g_StopLossMgr.SetIntPosBePt(Ticket, InpWhenToBePips*Pips,InpPointLockIn*Point);
                        
         Trail.type[0]       = InpTrailType;
         Trail.step_pt[0]    = InpTrailStepPoint;
         Trail.min_profit[0] = InpWhenToTrailPips*Pips;
         Trail.trail_pt[0]   = InpTrailPips*Pips;
           
         g_StopLossMgr.SetIntTrailStopPt(Ticket, Trail);
         FirstBuyTicket = Ticket;
         BuyResetFlag = true;
      }
      else
      printf(OrderLotSize);
   }
   if(g_TicketMgr.TotalTicketByCmd(OP_SELL,Symbol(),InpEa_MagicNo) == 0 && SellOptionflag
   && (Ask<ma) && Minute() > InpStartMinutes
   && (DayOfWeek() != 5 || (DayOfWeek() == 5 && Hour() < InpFridayBeHour))
   && (DayOfWeek() != 1 || (DayOfWeek() == 1 && Hour() >= InpMondayStartHour))
   )
   { 
      if(InpFirstTpPips > 0)
      {
         Tp = InpFirstTpPips*Pips;
      }
      Ticket = g_Trade.Sell(Symbol(),OrderLotSize,0,0,0,3,InpEa_MagicNo,0,InpComment,clrBlue);
      if(Ticket > 0)
      {              
         tp.val[0]      = Tp;                         
         tp.lot[0]      = OrderLotSize;  
   
         g_TakeProfitMgr.SetIntTakeProfitPt(Ticket,OrderLotSize,tp);
                     
         g_StopLossMgr.SetIntPosBePt(Ticket, InpWhenToBePips*Pips,InpPointLockIn*Point);
            
         Trail.type[0]       = InpTrailType;
         Trail.step_pt[0]    = InpTrailStepPoint;
         Trail.min_profit[0] = InpWhenToTrailPips*Pips;
         Trail.trail_pt[0]   = InpTrailPips*Pips;
  
         g_StopLossMgr.SetIntTrailStopPt(Ticket, Trail);  
         FirstSellTicket = Ticket; 
         SellResetFlag = true;                     
      }   
   }
   
   return true;
}

void C_FCS_IBL_M::GetOrderdetail()
{      
   trades = 0; 
   lots = 0; 
   Opnl = 0; 
   Buy.Opnl = 0; 
   Sell.Opnl = 0;         
   Buy.lots = 0;
   Sell.lots = 0; 
   Buy.trades = 0; 
   Sell.trades = 0;    
   SaveNearestBuyPrice = DBL_MAX;
   SaveNearestSellPrice = DBL_MIN;

   if(InpEnableAutoLotFlag && AccountBalance() > InpAutoLotValue)
   {   
      int AutoLotCount = (int)(AccountBalance()/InpAutoLotValue);
      OrderLotSize = NormalizeDouble(AutoLotCount * InpLot,2);
   }
   else
   {
      OrderLotSize = InpLot;
   } 
                                                
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == InpEa_MagicNo)
         {
            Opnl += OrderProfit()+OrderCommission()+OrderSwap();
            lots += OrderLots();
            trades +=1;
            if(OrderType() == OP_BUY)
            {
               Buy.lots += OrderLots();
               Buy.trades +=1;
               Buy.Opnl += OrderProfit()+OrderCommission()+OrderSwap();
               if(OrderOpenPrice() < SaveNearestBuyPrice)
               {
                  SaveNearestBuyPrice = OrderOpenPrice();
               }
            }
            if(OrderType() == OP_SELL)
            {
               Sell.lots += OrderLots();
               Sell.trades +=1;
               Sell.Opnl += OrderProfit()+OrderCommission()+OrderSwap();
               if(OrderOpenPrice() > SaveNearestSellPrice)
               {
                  SaveNearestSellPrice = OrderOpenPrice();
               } 
            }
         }
      }
      else
      {
         Print("OrderSelect returned the GetOrderdetail error of "+DoubleToStr(GetLastError()));         
      }
   }
   if(Buy.trades > 13)
   {
      Buy.trades = 13;
   }
   if(Sell.trades > 13)
   {
      Sell.trades = 13;
   }
   if(DayOfWeek() == 5 && Hour() >= InpFridayBeHour)
   {
      if(InpTotalBePips > 0 && Buy.trades > 0 && Buy.Opnl > InpTotalBePips*Buy.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE))
      {
         g_Trade.CloseAllBuy(3,InpEa_MagicNo,Symbol());
         BuyOptionflag = false;
      }
   }    
   if(DayOfWeek() == 5 && Hour() >= InpFridayBeHour)
   {      
      if(InpTotalBePips > 0 && Sell.trades > 0 && Sell.Opnl > InpTotalBePips*Sell.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE))
      {
         g_Trade.CloseAllSell(3,InpEa_MagicNo,Symbol());
         SellOptionflag = false;
      }   
   }
   if(Buy.trades >= InpBeLevel)
   {
      if(InpTotalBePips > 0 && Buy.trades > 0 && Buy.Opnl > InpTotalBePips*Buy.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE))
      {
         g_Trade.CloseAllBuy(3,InpEa_MagicNo,Symbol());
      }
   }    
   if(Sell.trades >= InpBeLevel)
   {      
      if(InpTotalBePips > 0 && Sell.trades > 0 && Sell.Opnl > InpTotalBePips*Sell.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE))
      {
         g_Trade.CloseAllSell(3,InpEa_MagicNo,Symbol());
      }   
   }
   
   if(InpMaxLostAmountUSD >= 1 && Buy.Opnl < (InpMaxLostAmountUSD*-1))
   {
      g_Trade.CloseAllBuy(3,InpEa_MagicNo,Symbol());
      BuyOptionflag = false;
   }
   if(InpMaxLostAmountUSD >= 1 && Sell.Opnl < (InpMaxLostAmountUSD*-1))
   {
      g_Trade.CloseAllSell(3,InpEa_MagicNo,Symbol());
      SellOptionflag = false;
   } 
   
   if(InpMaxLostPct >= 1 && AccountEquity() < AccountBalance() * (100 - InpMaxLostPct)/100)
   {
      g_Trade.CloseAllPosition(3,InpEa_MagicNo,Symbol());
      BuyOptionflag = false;
      SellOptionflag = false;
      printf(" CloseAllPosition InpMaxLostPct = "+DoubleToStr(InpMaxLostPct,2));
   }
   if(InpTotalTpPips > 0 && Buy.trades > 1 && Buy.Opnl > InpTotalTpPips*Buy.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE))
   {
      g_Trade.CloseAllBuy(3,InpEa_MagicNo,Symbol());
   }
   if(InpTotalTpPips > 0 && Sell.trades > 1 && Sell.Opnl > InpTotalTpPips*Sell.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE))
   {
      g_Trade.CloseAllSell(3,InpEa_MagicNo,Symbol());
   } 
   // trailing
   if(Buy.trades > 1)
   {
      if(BuyResetFlag == true)
      {
         g_TakeProfitMgr.DeleteIntTakeProfit(FirstBuyTicket);
         g_StopLossMgr.DeleteIntTrailStop(FirstBuyTicket);
         g_StopLossMgr.DeleteIntPosBe(FirstBuyTicket);
         BuyResetFlag = false;
      }
      if(BuyStartTrailing == false)
      {
         BuyTrailingPnL = InpTotalWhenToTrailPips*Buy.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE);      
      }
      if(Buy.Opnl > BuyTrailingPnL)
      {
         BuyTrailingPnL = Buy.Opnl;
         BuyStartTrailing = true;
      }
      if(BuyStartTrailing)
      {
         if(Buy.Opnl <= BuyTrailingPnL - (InpTotalTrailPips*Buy.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE)))
         {
            g_Trade.CloseAllBuy(3,InpEa_MagicNo,Symbol()); 
//            printf(BuyTrailingPnL);   
         }
      }
   }
   else
   {
      BuyStartTrailing = false;
      BuyTrailingPnL = InpTotalWhenToTrailPips*Buy.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE); 
   }
   
   if(Sell.trades > 1)
   {
      if(SellResetFlag == true)
      {   
         g_TakeProfitMgr.DeleteIntTakeProfit(FirstSellTicket);
         g_StopLossMgr.DeleteIntTrailStop(FirstSellTicket);
         g_StopLossMgr.DeleteIntPosBe(FirstSellTicket);
         SellResetFlag = false;
      }
      if(SellStartTrailing == false)
      {
         SellTrailingPnL = InpTotalWhenToTrailPips*Sell.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE);      
      }
      if(Sell.Opnl > SellTrailingPnL)
      {
         SellTrailingPnL = Sell.Opnl;
         SellStartTrailing = true;
//         printf(Sell.Opnl+", "+SellTrailingPnL); 
      }    
      if(SellStartTrailing)
      {
         if(Sell.Opnl <= SellTrailingPnL - (InpTotalTrailPips*Sell.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE)))
         {
            g_Trade.CloseAllSell(3,InpEa_MagicNo,Symbol()); 
//            printf(SellTrailingPnL+", "+Sell.Opnl+", "+(InpTotalTpPips*Sell.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE)));    
         }
      }
   }
   else
   {
      SellStartTrailing = false;
      SellTrailingPnL = InpTotalWhenToTrailPips*Sell.lots*10*MarketInfo(Symbol(),MODE_TICKVALUE);   
   }
       
   SetLabel("Symbol", Symbol(), White, 250, 20);
   SetLabel("Total", "TOTAL", White, 250, 40);   
   SetLabel("Buy", "BUY", White, 250, 60);
   SetLabel("Sell", "SELL", White, 250, 80);        
   SetLabel("Trades", "Trades", White, 160, 20);
   SetLabel("objTrades", DoubleToStr(trades,0), White, 160, 40);   
   SetLabel("BuyobjTrades", DoubleToStr(Buy.trades,0), White, 160, 60);   
   SetLabel("SellobjTrades", DoubleToStr(Sell.trades,0), White, 160, 80);     
   SetLabel("Lots", "Lots", White, 90, 20);  
   SetLabel("objLots", DoubleToStr(lots,2), White, 90, 40);   
   SetLabel("BuyobjLots", DoubleToStr(Buy.lots,2), White, 90, 60);   
   SetLabel("SellobjLots", DoubleToStr(Sell.lots,2), White, 90, 80);    
   SetLabel("OpenPnL", "PnL", White, 10, 20);
   SetLabel("objOpenPnL", DoubleToStr(Opnl,2), White, 20, 40);
   SetLabel("Buy.Opnl", DoubleToStr(Buy.Opnl,2), White, 20, 60);   
   SetLabel("Sell.Opnl", DoubleToStr(Sell.Opnl,2), White, 20, 80);
   SetLabel("AccountEquity()", DoubleToStr(AccountEquity(),2), Red, 20, 100); 
   SetLabel("BuyTrailingPnL", "BuyTrailingPnL ="+DoubleToStr(BuyTrailingPnL,2), clrOrangeRed, 20, 120); 
   SetLabel("SellTrailingPnL", "SellTrailingPnL ="+DoubleToStr(SellTrailingPnL,2), clrOrangeRed, 20, 140);
   SetLabel("BuyOptionflag", "BuyOptionflag ="+DoubleToStr(BuyOptionflag,0), clrOrangeRed, 20, 160); 
   SetLabel("SellOptionflag", "SellOptionflag ="+DoubleToStr(SellOptionflag,0), clrOrangeRed, 20, 180);
   SetLabel("ma", "ma ="+DoubleToStr(ma,5), clrOrangeRed, 20, 200); 
   
   SetLabel("ACCOUNT_LEVERAGE", "ACCOUNT_LEVERAGE ="+DoubleToStr(AccountInfoInteger(ACCOUNT_LEVERAGE),0), clrGreen, 0, 0,2);
   SetLabel("ACCOUNT_MARGIN_SO_SO", "ACCOUNT_MARGIN_SO_SO ="+DoubleToStr(AccountInfoDouble(ACCOUNT_MARGIN_SO_SO),0), clrGreen, 0, 20,2);
}

void  C_FCS_IBL_M::SetLabel(string name1, string text, color clr, int xdistance, int ydistance, int corner=1, int fontsize=15)
{
   name1 = obj_prefix+name1;
   ObjectCreate(name1, OBJ_LABEL, 0, 0,0);
   ObjectSet(name1, OBJPROP_XDISTANCE, xdistance);
   ObjectSet(name1, OBJPROP_YDISTANCE, ydistance);
   ObjectSet(name1, OBJPROP_CORNER, corner);
   ObjectSetText(name1, text, fontsize, "Arial", clr); 
}
