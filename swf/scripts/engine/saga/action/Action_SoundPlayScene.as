package engine.saga.action
{
   import engine.saga.Saga;
   import engine.sound.view.ISound;
   
   public class Action_SoundPlayScene extends Action
   {
       
      
      public var sound:ISound;
      
      public function Action_SoundPlayScene(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = def.id;
         saga.performSoundPlayScene(_loc1_);
         end();
      }
   }
}
