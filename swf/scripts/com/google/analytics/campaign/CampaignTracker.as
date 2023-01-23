package com.google.analytics.campaign
{
   import com.google.analytics.utils.Variables;
   
   public class CampaignTracker
   {
       
      
      public var id:String;
      
      public var source:String;
      
      public var clickId:String;
      
      public var name:String;
      
      public var medium:String;
      
      public var term:String;
      
      public var content:String;
      
      public function CampaignTracker(param1:String = "", param2:String = "", param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:String = "")
      {
         super();
         this.id = param1;
         this.source = param2;
         this.clickId = param3;
         this.name = param4;
         this.medium = param5;
         this.term = param6;
         this.content = param7;
      }
      
      private function _addIfNotEmpty(param1:Array, param2:String, param3:String) : void
      {
         if(param3 != "")
         {
            param3 = param3.split("+").join("%20");
            param3 = param3.split(" ").join("%20");
            param1.push(param2 + param3);
         }
      }
      
      public function isValid() : Boolean
      {
         if(this.id != "" || this.source != "" || this.clickId != "")
         {
            return true;
         }
         return false;
      }
      
      public function fromTrackerString(param1:String) : void
      {
         var _loc2_:String = param1.split(CampaignManager.trackingDelimiter).join("&");
         var _loc3_:Variables = new Variables(_loc2_);
         if(_loc3_.hasOwnProperty("utmcid"))
         {
            this.id = _loc3_["utmcid"];
         }
         if(_loc3_.hasOwnProperty("utmcsr"))
         {
            this.source = "-";
         }
         if(_loc3_.hasOwnProperty("utmccn"))
         {
            this.name = _loc3_["utmccn"];
         }
         if(_loc3_.hasOwnProperty("utmcmd"))
         {
            this.medium = _loc3_["utmcmd"];
         }
         if(_loc3_.hasOwnProperty("utmctr"))
         {
            this.term = _loc3_["utmctr"];
         }
         if(_loc3_.hasOwnProperty("utmcct"))
         {
            this.content = _loc3_["utmcct"];
         }
         if(_loc3_.hasOwnProperty("utmgclid"))
         {
            this.clickId = _loc3_["utmgclid"];
         }
      }
      
      public function toTrackerString() : String
      {
         var _loc1_:Array = [];
         this._addIfNotEmpty(_loc1_,"utmcid=",this.id);
         this._addIfNotEmpty(_loc1_,"utmcsr=","-");
         this._addIfNotEmpty(_loc1_,"utmgclid=",this.clickId);
         this._addIfNotEmpty(_loc1_,"utmccn=",this.name);
         this._addIfNotEmpty(_loc1_,"utmcmd=",this.medium);
         this._addIfNotEmpty(_loc1_,"utmctr=",this.term);
         this._addIfNotEmpty(_loc1_,"utmcct=",this.content);
         return _loc1_.join(CampaignManager.trackingDelimiter);
      }
   }
}
