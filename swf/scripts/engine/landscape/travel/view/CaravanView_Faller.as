package engine.landscape.travel.view
{
   import com.greensock.easing.Quad;
   import engine.landscape.model.Landscape;
   import engine.landscape.travel.model.Travel;
   import engine.landscape.travel.model.Travel_FallData;
   import engine.math.MathUtil;
   import engine.scene.model.Scene;
   import flash.utils.Dictionary;
   
   public class CaravanView_Faller
   {
       
      
      public var view:CaravanView;
      
      public var complete:Boolean;
      
      private var fall_elapsed_ms:int = 0;
      
      private var fall_duration_ms:int = 8000;
      
      private var fall_elevation:Number = 1000;
      
      private var fall_current:Number;
      
      private var fall_adjust_y_by_id:Dictionary;
      
      private var fall_adjust_rot_by_id:Dictionary;
      
      public function CaravanView_Faller(param1:CaravanView)
      {
         this.fall_current = this.fall_elevation;
         this.fall_adjust_y_by_id = new Dictionary();
         this.fall_adjust_rot_by_id = new Dictionary();
         super();
         this.view = param1;
         var _loc2_:Travel_FallData = param1.travel.fallData;
         this.fall_current = this.fall_elevation = _loc2_.distancePixels;
         this.fall_duration_ms = _loc2_.durationSecs * 1000;
      }
      
      public function cleanup() : void
      {
      }
      
      public function getFallDeltaY(param1:String) : Number
      {
         return this.fall_current + this._getAdjustYById(param1);
      }
      
      private function _getAdjustYById(param1:String) : Number
      {
         var _loc2_:* = this.fall_adjust_y_by_id[param1];
         if(_loc2_ == undefined)
         {
            _loc2_ = Math.random() * 100;
            this.fall_adjust_y_by_id[param1] = _loc2_;
         }
         return Quad.easeOut(this.fall_elapsed_ms,_loc2_,-_loc2_,this.fall_duration_ms);
      }
      
      private function _getAdjustRotById(param1:String) : Number
      {
         var _loc2_:* = this.fall_adjust_rot_by_id[param1];
         if(_loc2_ == undefined)
         {
            _loc2_ = MathUtil.lerp(-Math.PI,Math.PI,Math.random()) / 2;
            this.fall_adjust_rot_by_id[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public function update(param1:int) : void
      {
         if(this.complete)
         {
            return;
         }
         var _loc2_:Travel = !!this.view ? this.view.travel : null;
         var _loc3_:Landscape = !!_loc2_ ? _loc2_.landscape : null;
         var _loc4_:Scene = !!_loc3_ ? _loc3_.scene : null;
         if(!_loc4_)
         {
            return;
         }
         if(!_loc4_.ready && !_loc4_.lookingForReady)
         {
            return;
         }
         this.fall_elapsed_ms = Math.min(this.fall_elapsed_ms,this.fall_duration_ms);
         this.fall_current = Quad.easeOut(this.fall_elapsed_ms,this.fall_elevation,-this.fall_elevation,this.fall_duration_ms);
         this.fall_elapsed_ms += param1;
         if(this.fall_elapsed_ms >= this.fall_duration_ms)
         {
            this.complete = true;
         }
      }
      
      public function computeAngle(param1:Number, param2:String) : Number
      {
         if(this.complete || this.fall_current <= 0)
         {
            return param1;
         }
         var _loc3_:Number = this._getAdjustRotById(param2);
         return Quad.easeOut(this.fall_elapsed_ms,_loc3_,param1 - _loc3_,this.fall_duration_ms);
      }
   }
}
