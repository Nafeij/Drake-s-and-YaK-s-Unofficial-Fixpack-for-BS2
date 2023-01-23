package engine.landscape.travel.view
{
   import as3isolib.utils.IsoUtil;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.BitmapResource;
   
   public class CaravanViewGlow_SparkleGroup
   {
       
      
      public var dow:DisplayObjectWrapper;
      
      public var b:DisplayObjectWrapper;
      
      public var elapsed_ms:int = 0;
      
      public var lifespan_ms:int = 0;
      
      private var natwidth:int;
      
      public var started:Boolean;
      
      public var vars:CaravanViewGlow_SparkleGroupVars;
      
      public var bits:Vector.<DisplayObjectWrapper>;
      
      public var respawn_ms:int;
      
      public var respawning:Boolean;
      
      public function CaravanViewGlow_SparkleGroup(param1:BitmapResource, param2:CaravanViewGlow_SparkleGroupVars)
      {
         var _loc4_:DisplayObjectWrapper = null;
         this.bits = new Vector.<DisplayObjectWrapper>();
         super();
         this.dow = IsoUtil.createDisplayObjectWrapper(false);
         this.dow.visible = false;
         this.vars = param2;
         var _loc3_:int = 0;
         while(_loc3_ < this.vars.MIN_SPARKLES)
         {
            _loc4_ = param1.getWrapper();
            this.bits.push(_loc4_);
            this.dow.addChild(_loc4_);
            _loc3_++;
         }
      }
      
      private function respawn(param1:int) : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         for each(_loc2_ in this.bits)
         {
            _loc3_ = Math.random() * param1 / 2;
            _loc4_ = Math.random() * Math.PI * 2;
            _loc5_ = _loc3_ * Math.cos(_loc4_);
            _loc6_ = _loc3_ * Math.sin(_loc4_);
            _loc2_.x = _loc5_;
            _loc2_.y = _loc6_;
         }
         this.dow.visible = false;
         this.respawning = true;
         if(!this.started)
         {
            this.respawn_ms = Math.random() * (this.vars.PAUSE_MS + this.vars.BASE_LIFESPAN_MS + (this.vars.PAUSE_VARIANCE_MS + this.vars.BASE_LIFESPAN_VARIANCE_MS) / 2);
            this.started = true;
         }
         else
         {
            this.respawn_ms = this.vars.PAUSE_MS + Math.random() * this.vars.PAUSE_VARIANCE_MS;
         }
         this.elapsed_ms = 0;
         this.lifespan_ms = this.vars.BASE_LIFESPAN_MS + Math.random() * this.vars.BASE_LIFESPAN_VARIANCE_MS;
      }
      
      public function update(param1:int, param2:int) : void
      {
         if(!this.started)
         {
            this.respawn(param2);
         }
         this.elapsed_ms += param1;
         if(this.respawning)
         {
            if(this.elapsed_ms < this.respawn_ms)
            {
               return;
            }
            this.elapsed_ms -= this.respawn_ms;
            this.respawning = false;
            this.dow.visible = true;
         }
         var _loc3_:Number = Math.min(1,this.elapsed_ms / this.lifespan_ms);
         var _loc4_:Number = Math.min(1,Math.sin(_loc3_ * Math.PI));
         _loc4_ *= 0.6;
         this.dow.alpha = _loc4_;
         if(_loc3_ >= 1)
         {
            this.respawn(param2);
         }
      }
   }
}
