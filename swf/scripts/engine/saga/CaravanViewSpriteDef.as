package engine.saga
{
   import engine.landscape.travel.def.CartDef;
   
   public class CaravanViewSpriteDef
   {
       
      
      public var entityId:String;
      
      public var type:String;
      
      public var animid:String;
      
      public var rands:int;
      
      public var foot_lead:Number;
      
      public var foot_tail:Number;
      
      public var front:Boolean;
      
      public var back:int;
      
      public var gap_lead:Number = 1.7976931348623157e+308;
      
      public var gap_tail:Number = 1.7976931348623157e+308;
      
      public var pop_varname:String;
      
      public var pop_groupsize:int = 1;
      
      public var pop_mingroups:int = 0;
      
      public var pop_maxgroups:int = 10;
      
      public var disallow_first:Boolean;
      
      public var lead:String;
      
      public var trail:String;
      
      public var pop_forcemin:Boolean = false;
      
      public var cart_def:CartDef;
      
      public function CaravanViewSpriteDef()
      {
         super();
      }
      
      public function setDisallowFirst() : CaravanViewSpriteDef
      {
         this.disallow_first = true;
         return this;
      }
      
      public function setLead(param1:String) : CaravanViewSpriteDef
      {
         this.lead = param1;
         return this;
      }
      
      public function setTrail(param1:String) : CaravanViewSpriteDef
      {
         this.trail = param1;
         return this;
      }
      
      public function setPop(param1:String, param2:int, param3:int, param4:int, param5:Boolean = false) : CaravanViewSpriteDef
      {
         this.pop_varname = param1;
         this.pop_groupsize = param2;
         this.pop_mingroups = param3;
         this.pop_maxgroups = param4;
         this.pop_forcemin = param5;
         return this;
      }
      
      public function init(param1:String, param2:String, param3:int, param4:Number, param5:Number, param6:Boolean = false, param7:int = -1, param8:Number = 1.7976931348623157e+308, param9:Number = 1.7976931348623157e+308) : CaravanViewSpriteDef
      {
         this.type = param1;
         this.animid = param2;
         this.rands = param3;
         this.foot_lead = param4;
         this.foot_tail = param5;
         this.front = param6;
         this.back = param7;
         if(param8 == Number.MAX_VALUE)
         {
            this.gap_lead = param4;
         }
         else
         {
            this.gap_lead = param8;
         }
         if(param9 == Number.MAX_VALUE)
         {
            this.gap_tail = param5;
         }
         else
         {
            this.gap_tail = param9;
         }
         return this;
      }
      
      public function addCartDef(param1:CartDef) : CaravanViewSpriteDef
      {
         this.cart_def = param1;
         return this;
      }
   }
}
