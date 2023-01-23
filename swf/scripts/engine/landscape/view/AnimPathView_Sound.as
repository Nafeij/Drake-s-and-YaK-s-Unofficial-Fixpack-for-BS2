package engine.landscape.view
{
   import com.stoicstudio.platform.PlatformFlash;
   import engine.ability.def.StringNumberPair;
   import engine.landscape.def.AnimPathNodeSoundDef;
   import engine.saga.ISaga;
   import engine.saga.SagaInstance;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public class AnimPathView_Sound extends AnimPathViewNode
   {
       
      
      private var _hasPlayed:Boolean = false;
      
      private var _soundDef:AnimPathNodeSoundDef;
      
      public function AnimPathView_Sound(param1:AnimPathNodeSoundDef, param2:AnimPathView)
      {
         super(param1,param2);
         this._soundDef = param1;
         refreshParams();
      }
      
      private function _computeVolume() : Number
      {
         var _loc1_:Rectangle = this.sprite.getStageBounds();
         var _loc2_:int = PlatformFlash.stage.width;
         var _loc3_:int = PlatformFlash.stage.height;
         var _loc4_:int = _loc2_ / 2;
         var _loc5_:int = _loc3_ / 2;
         var _loc6_:int = Math.min(Math.abs(_loc1_.left - _loc4_),Math.abs(_loc1_.right - _loc4_));
         var _loc7_:int = Math.min(Math.abs(_loc1_.bottom - _loc5_),Math.abs(_loc1_.top - _loc5_));
         if(_loc1_.left <= _loc4_ && _loc1_.right >= _loc4_)
         {
            _loc6_ = 0;
         }
         if(_loc1_.top <= _loc5_ && _loc1_.bottom >= _loc5_)
         {
            _loc7_ = 0;
         }
         if(_loc6_ == 0 && _loc7_ == 0)
         {
            return 1;
         }
         var _loc8_:Number = _loc6_ / _loc4_;
         var _loc9_:Number = _loc7_ / _loc5_;
         var _loc10_:int = Math.max(_loc7_,_loc6_);
         var _loc11_:Number = Math.max(_loc8_,_loc9_);
         var _loc12_:Number = Math.max(0,1 - _loc11_);
         var _loc13_:Number = 1.5;
         _loc12_ *= _loc13_;
         _loc12_ *= _loc12_;
         return Math.min(1,_loc12_);
      }
      
      override public function evaluate(param1:int) : Matrix
      {
         var _loc5_:StringNumberPair = null;
         this.refreshParams();
         if(this._hasPlayed || param1 < _startTime_ms)
         {
            return null;
         }
         this._hasPlayed = true;
         var _loc2_:Number = this._computeVolume();
         if(_loc2_ <= 0)
         {
            return null;
         }
         var _loc3_:ISaga = SagaInstance.instance;
         if(!_loc3_)
         {
            view.logger.info("saga instance is null. Skipping sound ");
            return null;
         }
         var _loc4_:ActionDef = new ActionDef(null);
         _loc4_.type = ActionType.SOUND_PLAY_EVENT;
         _loc4_.id = this._soundDef.soundUrl;
         if(!this._soundDef.transcendent)
         {
            _loc4_.scene = "scene";
         }
         if(this._soundDef.params)
         {
            for each(_loc5_ in this._soundDef.params)
            {
               if(_loc4_.param)
               {
                  if(Boolean(view) && Boolean(view.logger))
                  {
                     view.logger.error("Sound clobbering previous param " + _loc4_.param + " in favor of later param " + _loc5_.id + " " + this);
                  }
               }
               _loc4_.param = _loc5_.id;
               _loc4_.varvalue = _loc5_.value;
               _loc4_.sound_volume = _loc2_;
            }
         }
         _loc3_.executeActionDef(_loc4_,null,null);
         return null;
      }
      
      override public function reset() : void
      {
         this._hasPlayed = false;
      }
   }
}
