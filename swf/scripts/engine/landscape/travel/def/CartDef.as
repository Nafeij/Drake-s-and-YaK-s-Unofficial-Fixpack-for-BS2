package engine.landscape.travel.def
{
   import engine.core.logging.ILogger;
   import engine.saga.vars.IVariableProvider;
   
   public class CartDef
   {
      
      public static const schema:Object = {
         "name":"CartDef",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "animId":{"type":"string"},
            "hasYox":{"type":"boolean"},
            "hasIdle":{"type":"boolean"},
            "foot_lead":{"type":"number"},
            "foot_tail":{"type":"number"},
            "unlockVar":{
               "type":"string",
               "optional":true
            },
            "disabled":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var _id:String;
      
      private var _animId:String;
      
      private var _hasYox:Boolean;
      
      private var _unlockVar:String;
      
      public var foot_lead:Number;
      
      public var foot_tail:Number;
      
      public var hasIdle:Boolean;
      
      public var disabled:Boolean;
      
      public function CartDef()
      {
         super();
      }
      
      public static function save(param1:CartDef) : Object
      {
         var _loc2_:Object = {
            "id":(!!param1._id ? param1._id : ""),
            "animId":(!!param1._animId ? param1._animId : ""),
            "hasYox":param1._hasYox,
            "hasIdle":param1.hasIdle,
            "foot_lead":param1.foot_lead,
            "foot_tail":param1.foot_tail
         };
         if(param1._unlockVar)
         {
            _loc2_.unlockVar = param1._unlockVar;
         }
         if(param1.disabled)
         {
            _loc2_.disabled = param1.disabled;
         }
         return _loc2_;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get animId() : String
      {
         return this._animId;
      }
      
      public function get hasYox() : Boolean
      {
         return this._hasYox;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : CartDef
      {
         this._id = param1.id;
         this._animId = param1.animId;
         this._hasYox = param1.hasYox;
         this.hasIdle = param1.hasIdle;
         this.foot_lead = param1.foot_lead;
         if(isNaN(this.foot_lead))
         {
            this.foot_lead = 0;
         }
         this.foot_tail = param1.foot_tail;
         if(isNaN(this.foot_tail))
         {
            this.foot_tail = 0;
         }
         this.disabled = param1.disabled;
         if(param1.unlockVar)
         {
            this._unlockVar = param1.unlockVar;
         }
         return this;
      }
      
      public function isValid(param1:IVariableProvider) : Boolean
      {
         if(!param1 || !this._unlockVar || this._unlockVar == "")
         {
            return !this.disabled;
         }
         return !this.disabled && param1.getVarBool(this._unlockVar);
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "Id: " + this.id;
         _loc1_ += "\nanimId: " + this.animId;
         _loc1_ += "\nhasYox: " + this.hasYox;
         _loc1_ += "\nHasIdle: " + this.hasIdle;
         _loc1_ += "\nfoot_lead: " + this.foot_lead;
         _loc1_ += "\nfoot_tail: " + this.foot_tail;
         _loc1_ += "\ndisabled: " + this.disabled;
         return _loc1_ + ("\nunlockVar: " + this._unlockVar);
      }
   }
}
