package engine.battle.behavior
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   
   public class WalkTilesSlideBehavior extends WalkTilesBehavior
   {
       
      
      protected var speed:Number;
      
      protected var duration:Number;
      
      protected var tween:TweenMax;
      
      public function WalkTilesSlideBehavior(param1:IBattleEntity)
      {
         super(param1);
      }
      
      override public function start(param1:IBattleMove, param2:Function) : void
      {
         super.start(param1,param2);
         this.speed = 2;
         this.duration = (param1.numSteps - 1) / this.speed;
         entity.logger.debug("WalkTilesBehavior.start speed=" + this.speed + ", steps=" + param1.numSteps + ", duration=" + this.duration);
         this.tween = TweenMax.to(this,this.duration,{
            "t":param1.numSteps - 1,
            "onComplete":this.tweenCompleteHandler,
            "ease":Linear.easeNone
         });
      }
      
      override protected function stop(param1:String) : void
      {
         if(stopped)
         {
            return;
         }
         if(this.tween)
         {
            this.tween.kill();
         }
         super.stop(param1);
      }
      
      protected function tweenCompleteHandler() : void
      {
         entity.logger.debug("WalkTilesBehavior.tweenCompleteHandler");
      }
   }
}
