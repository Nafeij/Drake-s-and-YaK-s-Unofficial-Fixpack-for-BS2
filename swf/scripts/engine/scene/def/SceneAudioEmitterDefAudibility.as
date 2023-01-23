package engine.scene.def
{
   import engine.landscape.model.Landscape;
   import engine.landscape.model.LandscapeLayer;
   
   public class SceneAudioEmitterDefAudibility
   {
       
      
      public var panX:Number = 0;
      
      public var volume:Number = 0;
      
      public var emitter:SceneAudioEmitterDef;
      
      public var audible:Boolean;
      
      public var layer:LandscapeLayer;
      
      private var landscape:Landscape;
      
      public function SceneAudioEmitterDefAudibility(param1:SceneAudioEmitterDef, param2:Landscape)
      {
         super();
         this.emitter = param1;
         this.landscape = param2;
         this.resolveLayer();
      }
      
      public function toString() : String
      {
         return this.emitter.event + ":" + this.audible + ":" + this.volume;
      }
      
      public function resolveLayer() : void
      {
         if(Boolean(this.emitter.layer) && Boolean(this.landscape.layerVis))
         {
            this.layer = this.landscape.layerVis.getLayerIfVisible(this.emitter.layer);
         }
         else
         {
            this.layer = null;
         }
      }
   }
}
