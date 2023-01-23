package engine.landscape.view
{
   import com.greensock.TweenMax;
   import engine.core.util.ColorTweener;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableEvent;
   import engine.saga.vars.VariableType;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.ISoundDriver;
   import engine.sound.ISoundEventId;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.SoundDef;
   
   public class WeatherManager_Particle implements ISoundDefBundleListener
   {
       
      
      public var manager:WeatherManager;
      
      public var name:String;
      
      private var _density:Number = 1;
      
      private var _gravity:Number = 1;
      
      private var _variance:Number = 1;
      
      private var _densityMod:Number = 1;
      
      public var color:uint = 4294967295;
      
      public var alpha:Number = 1;
      
      public var orients:Boolean;
      
      public var stretch:Number = 1;
      
      public var horizontalMarch:Number = 1;
      
      public var colorTweener:ColorTweener;
      
      protected var category_urls:Array;
      
      protected var category_counts:Array;
      
      protected var category_speed:Array;
      
      protected var category_alphas:Array;
      
      private var _varname_density:String;
      
      private var _varname_gravity:String;
      
      private var _varname_variance:String;
      
      private var _varname_color:String;
      
      private var _tweenDensity:TweenMax;
      
      private var _tweenGravity:TweenMax;
      
      public var fmodEvent:String;
      
      public var fmodHandle:ISoundEventId;
      
      public var fmodDensityParam:String;
      
      public var fmodDensityScale:Number = 1;
      
      private var _previousFmodParamValue:Number = -1;
      
      private var soundBundle:ISoundDefBundle;
      
      public function WeatherManager_Particle(param1:String, param2:WeatherManager, param3:String, param4:String, param5:String, param6:String)
      {
         this.colorTweener = new ColorTweener(this.color,this.tweenerSetColor);
         super();
         this.name = param1;
         this.manager = param2;
         this._varname_density = param3;
         this._varname_gravity = param4;
         this._varname_variance = param5;
         this._varname_color = param6;
      }
      
      public function getUrlsForCategory(param1:int) : Array
      {
         if(param1 < 0 || param1 >= this.category_urls.length)
         {
            throw new ArgumentError("not enough urls for " + this + " category " + param1);
         }
         return this.category_urls[param1];
      }
      
      public function getCountForCategory(param1:int) : Number
      {
         if(param1 < 0 || param1 >= this.category_counts.length)
         {
            throw new ArgumentError("not enough counts for " + this + " category " + param1);
         }
         return this.category_counts[param1];
      }
      
      public function getAlphaForCategory(param1:int) : Number
      {
         if(param1 < 0 || param1 >= this.category_alphas.length)
         {
            throw new ArgumentError("not enough alphas for " + this + " category " + param1);
         }
         return this.category_alphas[param1];
      }
      
      public function getSpeedForCategory(param1:int) : Number
      {
         if(param1 < 0 || param1 >= this.category_speed.length)
         {
            throw new ArgumentError("not enough speeds for " + this + " category " + param1);
         }
         return this.category_speed[param1];
      }
      
      public function toString() : String
      {
         return this.name;
      }
      
      public function cleanup() : void
      {
         this.stopAudio();
         this._tweenDensity = null;
         this._tweenGravity = null;
         this.colorTweener.cleanup();
         this.colorTweener = null;
         TweenMax.killTweensOf(this);
      }
      
      public function tweenGravity(param1:Number) : void
      {
         if(isNaN(param1))
         {
            return;
         }
         if(this._tweenGravity)
         {
            this._tweenGravity.kill();
            this._tweenGravity = null;
         }
         var _loc2_:Number = this.manager.computeTweenDuration(this._gravity);
         this._tweenGravity = TweenMax.to(this,_loc2_,{"gravity":param1});
      }
      
      public function tweenVariance(param1:Number) : void
      {
         if(isNaN(param1))
         {
            return;
         }
         var _loc2_:Number = this.manager.computeTweenDuration(this._gravity);
         TweenMax.to(this,_loc2_,{"variance":param1});
      }
      
      public function tweenDensity(param1:Number) : void
      {
         if(isNaN(param1))
         {
            return;
         }
         if(this._tweenDensity)
         {
            this._tweenDensity.kill();
            this._tweenDensity = null;
         }
         var _loc2_:Number = this.manager.computeTweenDuration(this._gravity);
         this._tweenDensity = TweenMax.to(this,_loc2_,{"density":param1});
      }
      
      public function variableHandler(param1:VariableEvent) : Boolean
      {
         switch(param1.value.def.name)
         {
            case this._varname_density:
               this.tweenDensity(param1.value.asNumber);
               break;
            case this._varname_gravity:
               this.tweenGravity(param1.value.asNumber);
               break;
            case this._varname_variance:
               this.tweenVariance(param1.value.asNumber);
               break;
            case this._varname_color:
               this.tweenColor(param1.value.asUnsigned);
               break;
            default:
               return false;
         }
         return true;
      }
      
      public function tweenColor(param1:uint) : void
      {
         var _loc2_:Number = !!this._density ? 3 : 0;
         this.colorTweener.tweenTo(param1,_loc2_);
      }
      
      public function getVariables(param1:IVariableBag) : void
      {
         if(!param1)
         {
            return;
         }
         this._density = param1.fetch(this._varname_density,VariableType.DECIMAL).asNumber;
         this._gravity = param1.fetch(this._varname_gravity,VariableType.DECIMAL).asNumber;
         this._variance = param1.fetch(this._varname_variance,VariableType.DECIMAL).asNumber;
         var _loc2_:IVariable = param1.fetch(this._varname_color,VariableType.DECIMAL);
         _loc2_.def.perCaravan = true;
         _loc2_.def.upperBound = uint.MAX_VALUE;
         _loc2_.def.lowerBound = 0;
         this.colorTweener.color = _loc2_.asUnsigned;
         this.tweenerSetColor(this.colorTweener.color);
      }
      
      public function get density() : Number
      {
         return this._density;
      }
      
      public function set density(param1:Number) : void
      {
         if(this._density == param1)
         {
            return;
         }
         this._density = param1;
         this.checkAudio();
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
         this.checkAudio();
      }
      
      private function checkAudio() : void
      {
         var _loc2_:Vector.<ISoundDef> = null;
         var _loc3_:SoundDef = null;
         var _loc4_:Number = NaN;
         if(!this.fmodEvent || !this.manager || !this.manager.saga)
         {
            return;
         }
         var _loc1_:ISoundDriver = this.manager.saga.sound.system.driver;
         if(this._density)
         {
            if(!this.soundBundle)
            {
               _loc2_ = new Vector.<ISoundDef>();
               _loc3_ = new SoundDef().setup(null,"density",this.fmodEvent);
               _loc2_.push(_loc3_);
               this.soundBundle = _loc1_.preloadSoundDefData(this.name,_loc2_);
               this.soundBundle.addListener(this);
               return;
            }
            if(!this.soundBundle.ok)
            {
               return;
            }
            if(!this.fmodHandle)
            {
               this.fmodHandle = _loc1_.playEvent(this.fmodEvent);
            }
            if(Boolean(this.fmodHandle) && Boolean(this.fmodDensityParam))
            {
               _loc4_ = this._density / this.fmodDensityScale;
               if(Math.abs(_loc4_ - this._previousFmodParamValue) > 0.05)
               {
                  this._previousFmodParamValue = this._density;
                  _loc1_.setEventParameter(this.fmodEvent,this.fmodDensityParam,_loc4_);
               }
            }
         }
         else
         {
            this.stopAudio();
         }
      }
      
      private function stopAudio() : void
      {
         if(!this.manager || !this.manager.saga || !this.manager.saga.sound || !this.manager.saga.sound.system)
         {
            return;
         }
         var _loc1_:ISoundDriver = this.manager.saga.sound.system.driver;
         if(!_loc1_)
         {
            return;
         }
         if(this.fmodHandle)
         {
            _loc1_.stopEvent(this.fmodHandle,false);
            this.fmodHandle = null;
         }
         this._previousFmodParamValue = -1;
         if(this.soundBundle)
         {
            this.soundBundle.removeListener(this);
            this.soundBundle = null;
         }
      }
      
      public function get gravity() : Number
      {
         return this._gravity;
      }
      
      public function set gravity(param1:Number) : void
      {
         this._gravity = param1;
      }
      
      public function get variance() : Number
      {
         return this._variance;
      }
      
      public function set variance(param1:Number) : void
      {
         this._variance = param1;
      }
      
      public function get densityMod() : Number
      {
         return this._densityMod;
      }
      
      public function set densityMod(param1:Number) : void
      {
         this._densityMod = param1;
      }
      
      private function tweenerSetColor(param1:uint) : void
      {
         this.color = param1;
         this.alpha = (this.color >> 24 & 255) / 255;
      }
   }
}
