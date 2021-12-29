//+------------------------------------------------------------------+
//|                                                           EA.mq5 |
//|                                      Copyright 2021, mql-ea Ltd. |
//|                                           https://www.mql-ea.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, mql-ea Ltd."
#property link      "https://www.mql-ea.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input string symbol="BTCUSDT";
string baseURL="https://fapi.binance.com/";
#define sym_category "Binance"
#define limit 2

input bool GetSymbols=false; // Get All Symbole (Use first time/ to update symbles)
int OnInit()
  {
  //------------
  string url_testConnection=baseURL+"/fapi/v1/ping";
 getprice(url_testConnection,"check");
  
  string url_symbol=baseURL+"/fapi/v1/exchangeInfo";
  if(GetSymbols)getprice(url_symbol,"updateSymbole");
  
  //CustomSymbolCreate(symbol,sym_category,0);
  //SymbolSelect(symbol,true);
  
  //if(!ChartOpen(symbol,PERIOD_CURRENT))Print(GetLastError());
  //Comment(mqlTFtobinTF(Period()));
  
 string url_history=baseURL+"fapi/v1/klines?symbol="+symbol+"&interval="+mqlTFtobinTF(Period())+"&limit="+limit;
 
 getprice(url_history,"updateHistory");
 
//---
   
//---
   return(INIT_SUCCEEDED);
  }
 
 bool getprice(string url,string task)
  {
   string cookie=NULL,headers;
   char   post[],result[];
   //string url="https://finance.yahoo.com";
//--- To enable access to the server, you should add URL "https://finance.yahoo.com"
//--- to the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"):
//--- Resetting the last error code
   ResetLastError();
//--- Downloading a html page from Yahoo Finance
   int res=WebRequest("GET",url,cookie,NULL,500,post,0,result,headers);
   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      MessageBox("Add the address '"+url+"' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      if(res==200)
        {
        if(task=="check")return true;
        //---------------update History------------------
        else if(task=="updateHistory"){
        int start=0,count=0;string _key="";MqlRates symRate[];
        string res_string=CharArrayToString(result);
          while(start<StringLen(res_string)){
          datetime _time=0,_closeTime=0;double _open=0,_high=0,_low=0,_close=0,_tick_volume=0,_spread=0,_real_volume=0,Quote_asset_volume=0
          ,Number_of_trades=0,Taker_buy_base_asset_volume=0,Taker_buy_quote_asset_volume=0,_ignore=0;
          
  //        struct MqlRates
  //{
  // datetime time;         // Period start time
  // double   open;         // Open price
  // double   high;         // The highest price of the period
  // double   low;          // The lowest price of the period
  // double   close;        // Close price
  // long     tick_volume;  // Tick volume
  // int      spread;       // Spread
  // long     real_volume;  // Trade volume
  //};
  
//  [
//  [
//    1499040000000,      // Open time
//    "0.01634790",       // Open
//    "0.80000000",       // High
//    "0.01575800",       // Low
//    "0.01577100",       // Close
//    "148976.11427815",  // Volume
//    1499644799999,      // Close time
//    "2434.19055334",    // Quote asset volume
//    308,                // Number of trades
//    "1756.87402397",    // Taker buy base asset volume
//    "28.46694368",      // Taker buy quote asset volume
//    "17928899.62484339" // Ignore.
//  ]
//]

          
          Print(res_string);
          
          
          if(start==0)_key="[[";else _key="[";
          
          _time=(int)getKeyValue(res_string,_key,",");
          _key="\"";
          _open=(double)getKeyValue(res_string,_key);
          _high=(double)getKeyValue(res_string,_key);
          _low=(double)getKeyValue(res_string,_key);
          _close=(double)getKeyValue(res_string,_key);
          _closeTime=(int)getKeyValue(res_string,_key);
          Quote_asset_volume=(double)getKeyValue(res_string,_key);
          Number_of_trades=(double)getKeyValue(res_string,_key);
          Taker_buy_base_asset_volume=(double)getKeyValue(res_string,_key);
          _ignore=(double)getKeyValue(res_string,_key);
          
          ArrayResize(symRate,count+1);
         
          symRate[count].time=_time;
          symRate[count].close=_close;
          symRate[count].high=_high;
          symRate[count].low=_low;
          symRate[count].open=_open;
          symRate[count].real_volume=_real_volume;
          symRate[count].tick_volume=0;
          symRate[count].spread=0;
          
          
          count++;
          
          start++;
          }
        CustomRatesReplace(symbol,symRate[0].time,symRate[count-1].time,symRate,0);
        
        return true;
         
         
           }
         
          
         //--------------update symboles--------------------
          
          else if(task=="updateSymbole"){
          string res_string=CharArrayToString(result);
          
          int start=0;string _key="";
          while(start<StringLen(res_string)){
          string sym="",baseCurrency="",profitCurrency="";
          
          _key="symbol\":\"";
          sym=getKeyValue(res_string,_key,start);          
          _key="baseAsset\":\"";
          baseCurrency=getKeyValue(res_string,_key);
          _key="quoteAsset\":\"";
          profitCurrency=getKeyValue(res_string,_key);
          
          if(sym!=""&&baseCurrency!=""&&profitCurrency!=""){
          CustomSymbolCreate(sym,sym_category,0);
          CustomSymbolSetString(sym,SYMBOL_CURRENCY_BASE,baseCurrency);
          CustomSymbolSetString(sym,SYMBOL_CURRENCY_PROFIT,profitCurrency);
          }
          start++;
          }
          //Comment(CharArrayToString(result));
          //string symbol=
          
          //CustomSymbolCreate(symbol,"Binance",0);
  //SymbolSelect(symbol,true);
            }
        }
      else
         PrintFormat("Downloading '%s' failed, error code %d",url,res);
         return false;
     }
  return false;
  }
int start=0;
string getKeyValue(string json,string key,string ending="\""){
Print(start);
          int keyValue_start=(StringFind(json,key,start))+StringLen(key);
          start=(StringFind(json,ending,keyValue_start+1));
          int len=start-keyValue_start;
          string value=(StringSubstr(json,keyValue_start,len));
          start+=StringLen(ending);
          Print(value,"  ",start);
       return  value;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
string TFtoString(int _period)
  {

   switch(_period)
     {
      case 0:
         return("Current");
      case 1:
         return("M1");
      case 5:
         return("M5");
      case 15:
         return("M15");
      case 30:
         return("M30");
      case 16385:
         return("H1");
      case 16388:
         return("H4");
      case 16408:
         return("D1");
      case 32769:
         return("W1");
      case 49153:
         return("Mn1");
      default:
         return(DoubleToString(_period, 0));
     }
  }
  
  //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string mqlTFtobinTF(int _period)   
  {

   switch(_period)
     {
      case 0:
         return("Current");
      case 1:
         return("1m");
      case 5:
         return("5m");
      case 15:
         return("15m");
      case 30:
         return("30m");
      case 16385:
         return("1h");
      case 16388:
         return("4h");
      case 16408:
         return("1d");
      case 32769:
         return("1w");
      case 49153:
         return("1mn");
      default:
         return(DoubleToString(_period, 0));
     }
  }
  
