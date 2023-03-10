//+------------------------------------------------------------------+
//|                                                Tester Trader.mq4 |
//|                                Copyright 2022, ©Ricardo Trindade |
//|                      https://www.linkedin.com/in/costa-trindade/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, ©Ricardo Trindade"
#property link      "https://www.linkedin.com/in/costa-trindade/"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Include External Libraries                                       |
//+------------------------------------------------------------------+
#include <Controls/Button.mqh>
#include <Controls/Edit.mqh>

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
extern double LotSize=0.01;
extern int    StopLoss=20;
extern int    TakeProfit=40;
extern int    PipsToBump=5;
extern int    SubWindow=0;
double        pips = Point();

//+------------------------------------------------------------------+
//| Declaring Objects                                                |
//+------------------------------------------------------------------+

//Buttons
CButton buy;
CButton sell;
CButton close;
CButton incStop;
CButton decStop;
CButton incTarget;
CButton decTarget;
CButton BuyStop;
CButton BuyLimit;
CButton SellStop;
CButton SellLimit;
CButton pendingUP;
CButton pendingDN;

//Edit Box
CEdit lots;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

   //**************************************************
   //Manipulation of Global Variables
   //**************************************************
   if(Digits==5||Digits==3) pips *= 10;

   //**************************************************
   //Create Objects
   //**************************************************
   CreateOBJs();

//---

   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

   if(!IsTesting()) return;
   CheckForButtonPress();
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

}

//+------------------------------------------------------------------+
//| Check For Button Pressed Function                                |
//+------------------------------------------------------------------+
void CheckForButtonPress() {

   //Buy Button
   if(buy.Pressed()) {
      
      buy.Pressed(false);
      PlaceOrder(OP_BUY);
      return;
   }
   
   //Sell Button
   if(sell.Pressed()) {
      
      sell.Pressed(false);
      PlaceOrder(OP_SELL);
      return;
   }
   
   //Close Button
   if(close.Pressed()) {
      
      close.Pressed(false);
      CloseOrder();
      return;
   }
   
   //Increase Stop Button
   if(incStop.Pressed()) {
      
      incStop.Pressed(false);
      ModifyStopOrder(PipsToBump);
      return;
   }
   
   //Decrease Stop Button
   if(decStop.Pressed()) {
      
      decStop.Pressed(false);
      ModifyStopOrder(-PipsToBump);
      return;
   }
   
   //Increase Target Button
   if(incTarget.Pressed()) {
      
      incTarget.Pressed(false);
      ModifyTarget(PipsToBump);
      return;
   }
   
   //Decrease Target Button
   if(decTarget.Pressed()) {
      
      decTarget.Pressed(false);
      ModifyTarget(-PipsToBump);
      return;
   }
   
   //BuyStop Button
   if(BuyStop.Pressed()) {
      
      BuyStop.Pressed(false);
      PlaceOrder(OP_BUYSTOP);
      return;
   }
   
   //BuyLimit Button
   if(BuyLimit.Pressed()) {
      
      BuyLimit.Pressed(false);
      PlaceOrder(OP_BUYLIMIT);
      return;
   }
   
   //SellStop Button
   if(SellStop.Pressed()) {
      
      SellStop.Pressed(false);
      PlaceOrder(OP_SELLSTOP);
      return;
   }
   
   //SellLimit Button
   if(SellLimit.Pressed()) {
      
      SellLimit.Pressed(false);
      PlaceOrder(OP_SELLLIMIT);
      return;
   }
}

//+------------------------------------------------------------------+
//| Modify Target Function                                           |
//+------------------------------------------------------------------+
void ModifyTarget(int value) {

   if(!OrderSelect(0,SELECT_BY_POS))return;
   if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit()+value*pips,0))
   Print("Unable to increase stop of the order!");
}

//+------------------------------------------------------------------+
//| Modify Stop Order Function                                       |
//+------------------------------------------------------------------+
void ModifyStopOrder(int value) {

   if(!OrderSelect(0,SELECT_BY_POS))return;
   if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+value*pips,OrderTakeProfit(),0))
   Print("Unable to increase stop of the order!");
}

//+------------------------------------------------------------------+
//| Close Order Function                                             |
//+------------------------------------------------------------------+
void CloseOrder() {

   if(!OrderSelect(0,SELECT_BY_POS))return;
   int type = OrderType(); 
   double closeprice = 0.0;
   
   switch(type) {
   
      case OP_BUY:       closeprice=Bid; break;
      case OP_BUYLIMIT:  closeprice=Ask; break;
      case OP_BUYSTOP:   closeprice=Ask; break;
      case OP_SELL:      closeprice=Ask; break;
      case OP_SELLLIMIT: closeprice=Ask; break;
      case OP_SELLSTOP:  closeprice=Ask; break;
   }
   
   if(!OrderClose(OrderTicket(),OrderLots(),closeprice,30))
   Print("Unable to close the order!");
}

//+------------------------------------------------------------------+
//| Place Order Function                                             |
//+------------------------------------------------------------------+
void PlaceOrder (int Type) {
   
   int ticket = -1;
      
   //Buy
   if(Type == OP_BUY) {
      ticket = OrderSend(Symbol(),Type,double(lots.Text()),Ask,30,Ask-(StopLoss*pips),Ask+(TakeProfit*pips));
      return;
   }
   
   //Sell
   if(Type == OP_SELL) {
      ticket = OrderSend(Symbol(),Type,double(lots.Text()),Bid,30,Bid+(StopLoss*pips),Bid-(TakeProfit*pips));
      return;
   }
   
   //BuyStop
   if(Type == OP_BUYSTOP) {
      double OpenPrice = Ask + 25*pips;
      ticket = OrderSend(Symbol(),Type,double(lots.Text()),OpenPrice,30,OpenPrice-(StopLoss*pips),OpenPrice+(TakeProfit*pips));
      return;
   }
   
   //BuyLimit
   if(Type == OP_BUYLIMIT) {
      double OpenPrice = Ask - 25*pips;
      ticket = OrderSend(Symbol(),Type,double(lots.Text()),OpenPrice,30,OpenPrice-(StopLoss*pips),OpenPrice+(TakeProfit*pips));
      return;
   }
   
   //SellLimit
   if(Type == OP_SELLLIMIT) {
      double OpenPrice = Bid + 25*pips;
      ticket = OrderSend(Symbol(),Type,double(lots.Text()),OpenPrice,30,OpenPrice+(StopLoss*pips),OpenPrice-(TakeProfit*pips));
      return;
   }
   
   //SellStop
   if(Type == OP_SELLSTOP) {
      double OpenPrice = Bid - 25*pips;
      ticket = OrderSend(Symbol(),Type,double(lots.Text()),OpenPrice,30,OpenPrice+(StopLoss*pips),OpenPrice-(TakeProfit*pips));
      return;
   }
}

//+------------------------------------------------------------------+
//| Create Objects                                                   |
//+------------------------------------------------------------------+
void CreateOBJs() {

   int    buttonWidth  = 100;
   int    buttonHeight = 35;
   int    FontSize1    = buttonWidth/4;
   int    FontSize2    = buttonWidth/5;
   int    FontSize3    = buttonWidth/10;
   string Font         = "Times New Roman";

   //buyButton
   buy.Create(0,"buyButton",SubWindow,0,0,buttonWidth,buttonHeight);
   buy.Text("Buy  ");
   buy.FontSize(FontSize1);
   buy.ColorBackground(clrGreen);
   buy.Color(clrBlack);
   buy.Font(Font);

   //sellButton
   sell.Create(0,"sellButton",SubWindow,buy.Right(),buy.Top(),buy.Right()+buttonWidth,buy.Bottom());
   sell.Text("Sell  ");
   sell.FontSize(FontSize1);
   sell.ColorBackground(clrRed);
   sell.Color(clrBlack);
   sell.Font(Font);

   //closeButton
   close.Create(0,"closeButton",SubWindow,sell.Right(),sell.Top(),sell.Right()+buttonWidth,sell.Bottom());
   close.Text("Close   ");
   close.FontSize(FontSize2);
   close.ColorBackground(clrGray);
   close.Color(clrBlack);
   close.Font(Font);

   //incStop
   incStop.Create(0,"incStopbutton",SubWindow,0,buttonHeight,int(buttonWidth*1.5),buttonHeight*2);
   incStop.Text("Stop+");
   incStop.FontSize(FontSize2);
   incStop.ColorBackground(clrGreen);
   incStop.Color(clrBlack);
   incStop.Font(Font);

   //decStop
   decStop.Create(0,"decStopbutton",SubWindow,0,buttonHeight*2,int(buttonWidth*1.5),buttonHeight*3);
   decStop.Text("Stop-");
   decStop.FontSize(FontSize2);
   decStop.ColorBackground(clrRed);
   decStop.Color(clrBlack);
   decStop.Font(Font);

   //incTarget
   incTarget.Create(0,"incTargetbutton",SubWindow,int(buttonWidth*1.5),buttonHeight,int(buttonWidth*1.5)*2,buttonHeight*2);
   incTarget.Text("Target+");
   incTarget.FontSize(FontSize2);
   incTarget.ColorBackground(clrGreen);
   incTarget.Color(clrBlack);
   incTarget.Font(Font);

   //decTarget
   decTarget.Create(0,"decTargetbutton",SubWindow,int(buttonWidth*1.5),buttonHeight*2,int(buttonWidth*3),buttonHeight*3);
   decTarget.Text("Target-");
   decTarget.FontSize(FontSize2);
   decTarget.ColorBackground(clrRed);
   decTarget.Color(clrBlack);
   decTarget.Font(Font);
   
   //Lots Edit Box
   lots.Create(0,"lots",SubWindow,sell.Left()+int(buttonWidth/4), sell.Bottom(), sell.Right()-int(buttonWidth/4),sell.Bottom()+int(buttonHeight/2));
   lots.Text(string(LotSize));
   lots.TextAlign(ALIGN_CENTER);
   
   //BuyStop Button
   BuyStop.Create(0,"BuyStop",SubWindow,buy.Right()-int(buttonWidth/4),buy.Top(),buy.Right(),buy.Top()+buttonHeight/2);
   BuyStop.Text("stp");
   BuyStop.FontSize(FontSize3);
   
   //BuyLimit Button
   BuyLimit.Create(0,"BuyLimit",SubWindow,buy.Right()-int(buttonWidth/4),BuyStop.Bottom(),buy.Right(),buy.Bottom());
   BuyLimit.Text("lmt");
   BuyLimit.FontSize(FontSize3);
   
   //SellLimit Button
   SellLimit.Create(0,"SellLimit",SubWindow,sell.Right()-int(buttonWidth/4),sell.Top(),sell.Right(),sell.Top()+buttonHeight/2);
   SellLimit.Text("lmt");
   SellLimit.FontSize(FontSize3);
   
   //SellStop Button
   SellStop.Create(0,"SellStop",SubWindow,sell.Right()-int(buttonWidth/4),SellLimit.Bottom(),sell.Right(),sell.Bottom());
   SellStop.Text("stp");
   SellStop.FontSize(FontSize3);

   //pendingUP Button
   pendingUP.Create(0,"pendingUP",SubWindow,close.Right()-int(buttonWidth/4),close.Top(),close.Right(),close.Top()+buttonHeight/2);
   pendingUP.Text("up");
   pendingUP.FontSize(FontSize3);
   
   //pendingDN Button
   pendingDN.Create(0,"pendingDN",SubWindow,close.Right()-int(buttonWidth/4),pendingUP.Bottom(),close.Right(),close.Bottom());
   pendingDN.Text("dn");
   pendingDN.FontSize(FontSize3);
}
//+------------------------------------------------------------------+
