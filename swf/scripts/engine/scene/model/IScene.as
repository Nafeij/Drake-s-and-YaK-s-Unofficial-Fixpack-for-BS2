package engine.scene.model
{
   import engine.core.IUpdateable;
   import engine.core.render.BoundedCamera;
   import engine.saga.ISaga;
   import engine.scene.SceneContext;
   import engine.scene.def.ISceneDef;
   import engine.sound.ISoundDefBundleListener;
   
   public interface IScene extends IUpdateable, ISoundDefBundleListener
   {
       
      
      function get saga() : ISaga;
      
      function get context() : SceneContext;
      
      function get camera() : BoundedCamera;
      
      function get def() : ISceneDef;
      
      function disableStartPan() : void;
      
      function get ready() : Boolean;
   }
}
