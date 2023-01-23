package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.saga.ISaga;
   import engine.saga.SagaInstance;
   
   public class Op_SagaVar extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SagaVar",
         "properties":{
            "name":{"type":"string"},
            "expression":{"type":"string"},
            "prereq":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      private var saga:ISaga;
      
      private var expression:String;
      
      private var name:String;
      
      private var prereq:String;
      
      private var _prereqFailed:Boolean = false;
      
      public function Op_SagaVar(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.saga = SagaInstance.instance;
         this.expression = param1.params.expression;
         this.name = param1.params.name;
         this.prereq = param1.params.prereq;
      }
      
      override public function execute() : EffectResult
      {
         if(!this.saga)
         {
            return EffectResult.FAIL;
         }
         if(Boolean(this.prereq) && !this.saga.expression.evaluate(this.prereq,false))
         {
            this._prereqFailed = true;
            logger.info("Prereq false [" + this.prereq + "] for " + this);
            return EffectResult.FAIL;
         }
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(fake || !this.saga || this._prereqFailed)
         {
            return;
         }
         var _loc1_:Number = this.saga.expression.evaluate(this.expression,true);
         this.saga.setVar(this.name,_loc1_);
      }
   }
}
