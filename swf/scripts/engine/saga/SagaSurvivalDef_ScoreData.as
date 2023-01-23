package engine.saga
{
   import engine.core.locale.Locale;
   
   public class SagaSurvivalDef_ScoreData
   {
       
      
      public var name:String;
      
      public var descending:Boolean;
      
      public var max:int;
      
      public var min:int;
      
      public var factor:Number = 1;
      
      public var maxDisplayScore:int;
      
      public function SagaSurvivalDef_ScoreData(param1:String, param2:Boolean, param3:int, param4:int, param5:Number)
      {
         super();
         this.name = param1;
         this.descending = param2;
         this.max = param4;
         this.min = param3;
         this.factor = param5;
         this.maxDisplayScore = (param4 - param3) * param5;
      }
      
      public function computeScore(param1:Saga) : int
      {
         var _loc5_:* = false;
         if(this.descending)
         {
            _loc5_ = param1.survivalProgress >= param1.survivalTotal;
            if(!_loc5_)
            {
               return 0;
            }
         }
         var _loc2_:int = param1.getVarInt("survival_win_" + this.name + "_num");
         var _loc3_:int = Math.max(0,_loc2_ - this.min);
         if(this.descending)
         {
            _loc3_ = this.max - Math.max(this.min,_loc2_);
         }
         var _loc4_:int = _loc3_ * this.factor;
         param1.setVar("survival_win_" + this.name + "_score",_loc4_);
         return _loc4_;
      }
      
      public function getDisplayString(param1:Locale) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(this.factor == int(this.factor))
         {
            _loc3_ = int(this.factor).toString();
         }
         else
         {
            _loc3_ = this.factor.toFixed(1);
         }
         _loc2_ = "survival_win_score_";
         _loc2_ += this.descending ? "des" : "asc";
         var _loc4_:String = param1.translateGui(_loc2_);
         var _loc5_:String = param1.translateGui("survival_win_scorename_" + this.name);
         _loc4_ = _loc4_.replace("{scorename}",_loc5_);
         _loc4_ = _loc4_.replace("{max}",this.max);
         return _loc4_.replace("{factor}",_loc3_);
      }
   }
}
