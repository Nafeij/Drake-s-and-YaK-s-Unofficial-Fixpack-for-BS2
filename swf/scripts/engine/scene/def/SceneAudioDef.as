package engine.scene.def
{
   import engine.core.render.Camera;
   import engine.landscape.model.Landscape;
   import engine.saga.vars.IVariableBag;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SceneAudioDef extends EventDispatcher
   {
      
      public static var EVENT_EMITTERS:String = "SceneAudioDef.EVENT_EMITTERS";
       
      
      public var loadedJson:String;
      
      public var url:String;
      
      public var emitters:Vector.<SceneAudioEmitterDef>;
      
      public var scene:SceneDef;
      
      public function SceneAudioDef(param1:SceneDef)
      {
         this.emitters = new Vector.<SceneAudioEmitterDef>();
         super();
         this.scene = param1;
      }
      
      public static function _updateAudibilitiesForListener(param1:Camera, param2:Vector.<SceneAudioEmitterDefAudibility>, param3:Vector.<SceneAudioEmitterDef>, param4:Landscape, param5:IVariableBag) : Vector.<SceneAudioEmitterDefAudibility>
      {
         var _loc6_:SceneAudioEmitterDefAudibility = null;
         var _loc7_:SceneAudioEmitterDef = null;
         if(!param2 || param2.length != param3.length)
         {
            param2 = new Vector.<SceneAudioEmitterDefAudibility>();
            for each(_loc7_ in param3)
            {
               param2.push(new SceneAudioEmitterDefAudibility(_loc7_,param4));
            }
         }
         for each(_loc6_ in param2)
         {
            if(!_loc6_.emitter.checkConditions(param5))
            {
               _loc6_.audible = false;
            }
            else
            {
               _loc6_.emitter.checkAudibilityForListener(param1,_loc6_,param4);
            }
         }
         return param2;
      }
      
      public function updateAudibilitiesForListener(param1:Camera, param2:Vector.<SceneAudioEmitterDefAudibility>, param3:Vector.<SceneAudioEmitterDef>, param4:Landscape, param5:IVariableBag) : Vector.<SceneAudioEmitterDefAudibility>
      {
         var _loc7_:SceneAudioEmitterDefAudibility = null;
         var _loc8_:SceneAudioEmitterDef = null;
         var _loc6_:int = int(this.emitters.length);
         if(param3)
         {
            _loc6_ += param3.length;
         }
         if(!param2 || param2.length != _loc6_)
         {
            param2 = new Vector.<SceneAudioEmitterDefAudibility>();
            for each(_loc8_ in this.emitters)
            {
               param2.push(new SceneAudioEmitterDefAudibility(_loc8_,param4));
            }
            if(param3)
            {
               for each(_loc8_ in param3)
               {
                  param2.push(new SceneAudioEmitterDefAudibility(_loc8_,param4));
               }
            }
         }
         for each(_loc7_ in param2)
         {
            if(!_loc7_.emitter.checkConditions(param5))
            {
               _loc7_.audible = false;
            }
            else
            {
               _loc7_.emitter.checkAudibilityForListener(param1,_loc7_,param4);
            }
         }
         return param2;
      }
      
      public function addNewEmitter(param1:Number, param2:Number) : SceneAudioEmitterDef
      {
         var _loc3_:SceneAudioEmitterDef = new SceneAudioEmitterDef();
         _loc3_.source.setTo(param1 - 100,param2 - 50,200,100);
         this.emitters.push(_loc3_);
         dispatchEvent(new Event(EVENT_EMITTERS));
         return _loc3_;
      }
      
      public function cloneEmitter(param1:SceneAudioEmitterDef) : SceneAudioEmitterDef
      {
         var _loc2_:SceneAudioEmitterDef = param1.clone();
         this.emitters.push(_loc2_);
         dispatchEvent(new Event(EVENT_EMITTERS));
         return _loc2_;
      }
      
      public function promoteEmitter(param1:SceneAudioEmitterDef) : void
      {
         var _loc2_:int = this.emitters.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.emitters.splice(_loc2_,1);
            this.emitters.splice(_loc2_ - 1,0,param1);
            dispatchEvent(new Event(EVENT_EMITTERS));
         }
      }
      
      public function demoteEmitter(param1:SceneAudioEmitterDef) : void
      {
         var _loc2_:int = this.emitters.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.emitters.length - 1)
         {
            this.emitters.splice(_loc2_,1);
            this.emitters.splice(_loc2_ + 1,0,param1);
            dispatchEvent(new Event(EVENT_EMITTERS));
         }
      }
      
      public function removeEmitter(param1:SceneAudioEmitterDef) : void
      {
         var _loc2_:int = this.emitters.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.emitters.splice(_loc2_,1);
            dispatchEvent(new Event(EVENT_EMITTERS));
         }
      }
      
      public function notifyEmitters() : void
      {
         dispatchEvent(new Event(EVENT_EMITTERS));
      }
   }
}
