package engine.landscape.travel.view
{
   import engine.saga.CaravanViewSpriteDef;
   
   public class CaravanViewTypeInfo
   {
       
      
      public var type:String;
      
      public var animid:String;
      
      public var rands:int;
      
      public var foot_lead:Number;
      
      public var foot_tail:Number;
      
      public var front:Boolean;
      
      public var back:int;
      
      public var gap_lead:Number;
      
      public var gap_tail:Number;
      
      public var pop_varname:String;
      
      public var pop_groupsize:int = 1;
      
      public var pop_mingroups:int = 0;
      
      public var pop_maxgroups:int = 10;
      
      public var disallow_first:Boolean;
      
      public var lead:String;
      
      public var trail:String;
      
      public var has_idle:Boolean = true;
      
      public function CaravanViewTypeInfo()
      {
         super();
      }
      
      public function init(param1:String, param2:String, param3:int, param4:Number, param5:Number, param6:Boolean, param7:int, param8:Number, param9:Number) : CaravanViewTypeInfo
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
      
      public function fromDef(param1:CaravanViewSpriteDef) : CaravanViewTypeInfo
      {
         this.type = param1.type;
         this.animid = param1.animid;
         this.rands = param1.rands;
         this.foot_lead = param1.foot_lead;
         this.foot_tail = param1.foot_tail;
         this.front = param1.front;
         this.back = param1.back;
         this.gap_lead = param1.gap_lead;
         this.gap_tail = param1.gap_tail;
         this.pop_varname = param1.pop_varname;
         this.pop_groupsize = param1.pop_groupsize;
         this.pop_mingroups = param1.pop_mingroups;
         this.pop_maxgroups = param1.pop_maxgroups;
         this.disallow_first = param1.disallow_first;
         this.lead = param1.lead;
         this.trail = param1.trail;
         this.has_idle = !!param1.cart_def ? param1.cart_def.hasIdle : true;
         return this;
      }
   }
}
