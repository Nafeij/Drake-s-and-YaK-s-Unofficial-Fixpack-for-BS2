package game.gui.page
{
   import engine.core.analytic.Ga;
   import engine.core.analytic.GmA;
   import engine.core.logging.ILogger;
   import engine.core.util.MemoryReporter;
   import engine.core.util.StringUtil;
   import engine.gui.page.PageState;
   import flash.utils.getTimer;
   import starling.textures.Texture;
   
   public class ScenePageFrameTimeMonitor
   {
      
      private static var GA_MEM_THRESHOLD_MB:int = 300;
       
      
      private var sp:ScenePage;
      
      private var count:int;
      
      private var totalMs:int;
      
      private var maxMs:int;
      
      private var minMs:int = 1000000;
      
      private var url:String;
      
      private var start:int;
      
      private var maxMemMb:int;
      
      private var mr:MemoryReporter;
      
      public function ScenePageFrameTimeMonitor(param1:ScenePage, param2:MemoryReporter)
      {
         super();
         this.sp = param1;
         this.url = param1.scene._def.url;
         this.mr = param2;
      }
      
      public function update(param1:int) : void
      {
         if(this.sp.state == PageState.LOADING || this.sp.manager.loading)
         {
            return;
         }
         if(!this.sp.scene.ready)
         {
            return;
         }
         if(!this.start)
         {
            this.start = getTimer();
         }
         this.totalMs += param1;
         this.maxMs = Math.max(param1,this.maxMs);
         this.minMs = Math.min(param1,this.minMs);
         this.maxMemMb = Math.max(this.maxMemMb,this.mr.currentMb);
         ++this.count;
      }
      
      public function report(param1:ILogger) : void
      {
         var _loc2_:int = getTimer();
         var _loc3_:int = _loc2_ - this.start;
         var _loc4_:int = _loc3_ / 1000;
         var _loc5_:int = this.totalMs / this.count;
         var _loc6_:String = StringUtil.getBasename(this.url);
         if(param1.isDebugEnabled)
         {
            param1.debug("FRAMETIME: " + this.url + " dur=" + _loc4_ + " s, frametime=" + _loc5_ + " ms, max=" + this.maxMs + ", min=" + this.minMs + " textures=" + Texture.textureCount);
         }
         Ga.trackSceneFrameTime(_loc6_,_loc5_,this.maxMs);
         if(this.maxMemMb > GA_MEM_THRESHOLD_MB)
         {
            Ga.trackSceneMemory(_loc6_,this.maxMemMb);
         }
         GmA.trackCustom("frametime",_loc5_);
         if(_loc5_ > 50)
         {
            GmA.trackHighFrametime(_loc5_);
         }
         if(this.maxMemMb > 1300)
         {
            GmA.trackHighMemory(this.maxMemMb);
         }
      }
   }
}
