package engine.anim.def
{
   import engine.anim.view.Anim;
   import engine.anim.view.IAnim;
   import engine.core.logging.ILogger;
   import engine.resource.ResourceGroup;
   import engine.resource.ResourceManager;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class AnimLibrary extends EventDispatcher implements IAnimLibrary
   {
       
      
      public var animDefLayers:Vector.<AnimDefLayer>;
      
      public var animDefLayersById:Dictionary;
      
      public var orientedAnims:Dictionary;
      
      public var mixes:Dictionary;
      
      protected var facingClazz:Class;
      
      protected var logger:ILogger;
      
      public var locos:Dictionary;
      
      public var _url:String;
      
      public var resourceGroup:ResourceGroup;
      
      protected var _offsetsByFacing:Dictionary;
      
      public var _animsScale:Number = 1;
      
      public var _animsAlpha:Number = 1;
      
      public var _animsColor:uint = 4294967295;
      
      public var _mixDefaultName:String;
      
      private var variations:Dictionary;
      
      public function AnimLibrary(param1:String, param2:ILogger)
      {
         this.animDefLayers = new Vector.<AnimDefLayer>();
         this.animDefLayersById = new Dictionary();
         this.orientedAnims = new Dictionary();
         this.mixes = new Dictionary();
         this.locos = new Dictionary();
         this.variations = new Dictionary();
         super();
         this.resourceGroup = new ResourceGroup(this,param2);
         this._url = param1;
         this.logger = param2;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function resolve(param1:ResourceManager) : void
      {
      }
      
      public function cleanup() : void
      {
         var _loc1_:AnimDefLayer = null;
         this.resourceGroup.release();
         this.resourceGroup = null;
         for each(_loc1_ in this.animDefLayers)
         {
            _loc1_.cleanup();
         }
         this.animDefLayers = null;
         this.animDefLayersById = null;
         this.orientedAnims = null;
         this.mixes = null;
         this.facingClazz = null;
         this.logger = null;
         this.locos = null;
      }
      
      public function addAnimLoco(param1:AnimLoco) : void
      {
         this.locos[param1.id] = param1;
      }
      
      public function get layerCount() : int
      {
         return this.animDefLayers.length;
      }
      
      public function getLayerId(param1:int) : String
      {
         return this.animDefLayers[param1].layer;
      }
      
      public function getAnimDef(param1:String, param2:String) : IAnimDef
      {
         param1 = !!param1 ? param1 : "";
         var _loc3_:AnimDefLayer = !!this.animDefLayersById ? this.animDefLayersById[param1] : null;
         return !!_loc3_ ? _loc3_.animDefsByName[param2] : null;
      }
      
      public function addAnimLayer(param1:String, param2:String, param3:Array, param4:Array) : AnimDefLayer
      {
         param1 = !!param1 ? param1 : "";
         var _loc5_:AnimDefLayer = this.animDefLayersById[param1];
         if(!_loc5_)
         {
            _loc5_ = new AnimDefLayer(param1,param2,param3,param4);
            this.animDefLayersById[param1] = _loc5_;
            this.animDefLayers.push(_loc5_);
            return _loc5_;
         }
         throw new IllegalOperationError("Cannot re-create the layer");
      }
      
      public function addAnimDef(param1:String, param2:IAnimDef, param3:Boolean) : void
      {
         param1 = !!param1 ? param1 : "";
         var _loc4_:AnimDefLayer = this.animDefLayersById[param1];
         if(!_loc4_)
         {
            throw IllegalOperationError("Create the layer before adding anims to it");
         }
         _loc4_.addAnimDef(param2,param3);
      }
      
      public function addOrientedAnims(param1:OrientedAnimsDef) : void
      {
         this.orientedAnims[param1.name] = param1;
      }
      
      public function getAnim(param1:String, param2:String, param3:Function, param4:Function) : IAnim
      {
         param1 = !!param1 ? param1 : "";
         var _loc5_:IAnimDef = this.getAnimDef(param1,param2);
         if(Boolean(_loc5_) && Boolean(_loc5_.clip))
         {
            return new Anim(_loc5_,param3,param4,this.logger);
         }
         return null;
      }
      
      public function hasOrientedAnims(param1:String, param2:String) : Boolean
      {
         param1 = !!param1 ? param1 : "";
         var _loc3_:OrientedAnimsDef = this.orientedAnims[param2];
         var _loc4_:AnimDefLayer = this.animDefLayersById[param1];
         if(Boolean(_loc4_) && _loc4_.isOmittedOrient(param2))
         {
            return false;
         }
         if(_loc3_ != null)
         {
            return true;
         }
         return false;
      }
      
      public function getOrientedAnims(param1:String, param2:String, param3:Function, param4:Function) : OrientedAnims
      {
         param1 = !!param1 ? param1 : "";
         var _loc5_:OrientedAnimsDef = this.orientedAnims[param2];
         if(_loc5_)
         {
            return new OrientedAnims(param1,_loc5_,this,param3,param4,this.logger);
         }
         return null;
      }
      
      public function getAnimMix(param1:String, param2:String, param3:Function) : OrientedAnimMix
      {
         param1 = !!param1 ? param1 : "";
         var _loc4_:AnimMixDef = this.mixes[param2];
         if(_loc4_)
         {
            return new OrientedAnimMix(param1,_loc4_,this,param3,this.logger);
         }
         return null;
      }
      
      public function addAnimMixDef(param1:AnimMixDef) : void
      {
         if(param1.mixdefault)
         {
            this._mixDefaultName = param1.name;
         }
         this.mixes[param1.name] = param1;
      }
      
      public function getAnimLayerSourceLayerId(param1:String) : String
      {
         param1 = !!param1 ? param1 : "";
         var _loc2_:AnimDefLayer = this.animDefLayersById[param1];
         return !!_loc2_ ? _loc2_.sourceLayerId : null;
      }
      
      public function getAnimLayerOmitAnims(param1:String) : Array
      {
         param1 = !!param1 ? param1 : "";
         var _loc2_:AnimDefLayer = this.animDefLayersById[param1];
         return !!_loc2_ ? _loc2_.omita : null;
      }
      
      public function getAnimLayerOmitOrients(param1:String) : Array
      {
         param1 = !!param1 ? param1 : "";
         var _loc2_:AnimDefLayer = this.animDefLayersById[param1];
         return !!_loc2_ ? _loc2_.omito : null;
      }
      
      public function getExplicitAnimDefs(param1:String) : Vector.<IAnimDef>
      {
         param1 = !!param1 ? param1 : "";
         var _loc2_:AnimDefLayer = this.animDefLayersById[param1];
         return !!_loc2_ ? _loc2_.explicitAnimDefs : null;
      }
      
      public function getAllAnimDefs(param1:String) : Vector.<IAnimDef>
      {
         param1 = !!param1 ? param1 : "";
         var _loc2_:AnimDefLayer = this.animDefLayersById[param1];
         return !!_loc2_ ? _loc2_.allAnimDefs : null;
      }
      
      public function get errors() : int
      {
         var _loc2_:OrientedAnimsDef = null;
         var _loc3_:AnimMixDef = null;
         var _loc4_:String = null;
         var _loc5_:AnimMixEntryDef = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.orientedAnims)
         {
            for each(_loc4_ in _loc2_.animsByFacing)
            {
               if(!this.getAnimDef(null,_loc4_))
               {
                  _loc1_++;
                  this.logger.error("AnimationLibrary OrientedAnimsDef " + _loc2_.name + " references invalid anim [" + _loc4_ + "] in " + this._url);
               }
            }
         }
         for each(_loc3_ in this.mixes)
         {
            for each(_loc5_ in _loc3_.entries)
            {
               if(!(_loc5_.anim in this.orientedAnims))
               {
                  _loc1_++;
                  this.logger.error("AnimationLibrary AnimMixDef " + _loc2_.name + " references invalid anim [" + _loc5_.anim + "] in " + this._url);
               }
            }
         }
         return _loc1_;
      }
      
      public function getLoco(param1:String) : AnimLoco
      {
         return this.locos[!!param1 ? param1 : ""];
      }
      
      public function variation(param1:int) : AnimLibrary
      {
         var _loc2_:AnimLibrary = this.variations[param1];
         if(!_loc2_)
         {
            _loc2_ = this.makeVariation(param1);
            this.variations[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      private function makeVariation(param1:int) : AnimLibrary
      {
         return this;
      }
      
      public function getOffsetByFacing(param1:IAnimFacing, param2:Point) : Point
      {
         if(!this._offsetsByFacing)
         {
            return param2;
         }
         var _loc3_:Point = this._offsetsByFacing[param1];
         return !!_loc3_ ? _loc3_ : param2;
      }
      
      public function setOffsetByFacing(param1:IAnimFacing, param2:Number, param3:Number) : Point
      {
         var _loc4_:Point = new Point(param2,param3);
         if(!this._offsetsByFacing)
         {
            this._offsetsByFacing = new Dictionary();
         }
         this._offsetsByFacing[param1] = _loc4_;
         return _loc4_;
      }
      
      public function get offsetsByFacing() : Dictionary
      {
         return this._offsetsByFacing;
      }
      
      public function set animsScale(param1:Number) : void
      {
         this._animsScale = param1;
      }
      
      public function set animsAlpha(param1:Number) : void
      {
         this._animsAlpha = param1;
      }
      
      public function set animsColor(param1:uint) : void
      {
         this._animsColor = param1;
      }
      
      public function get animsScale() : Number
      {
         return this._animsScale;
      }
      
      public function get animsAlpha() : Number
      {
         return this._animsAlpha;
      }
      
      public function get animsColor() : uint
      {
         return this._animsColor;
      }
      
      public function findDefaultAmbientMix() : String
      {
         if(this._mixDefaultName)
         {
            return this._mixDefaultName;
         }
         var _loc1_:String = "mix_idle";
         if(this.mixes[_loc1_])
         {
            return _loc1_;
         }
         var _loc2_:int = 0;
         var _loc3_:* = this.mixes;
         for(_loc1_ in _loc3_)
         {
            return _loc1_;
         }
         return null;
      }
   }
}
