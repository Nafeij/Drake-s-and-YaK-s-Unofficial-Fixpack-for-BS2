package engine.entity.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.def.IsoAnimLibraryResource;
   import engine.battle.def.IsoVfxLibraryResource;
   import engine.resource.AnimClipResource;
   import engine.resource.BitmapResource;
   import engine.resource.IResource;
   import engine.resource.IResourceGroup;
   import engine.resource.IResourceManager;
   import engine.sound.def.SoundLibraryResource;
   import engine.sound.view.SoundController;
   
   public class EntityAssetBundle extends ResourceAssetBundle implements IEntityAssetBundle
   {
       
      
      public var appearance:IEntityAppearanceDef;
      
      public var _eps:IEntityAssetBundleManager;
      
      public var _alr:IsoAnimLibraryResource;
      
      public var _vlr:IsoVfxLibraryResource;
      
      public var _slr:SoundLibraryResource;
      
      public var _propAnimClipResource:AnimClipResource;
      
      public var _shadowBitmapResource:BitmapResource;
      
      public var _goAnimationRes:AnimClipResource;
      
      public var _speechBubbleRes:BitmapResource;
      
      public var _portraitRes:AnimClipResource;
      
      public var _versusRes:BitmapResource;
      
      public var withSounds:Boolean;
      
      private var _soundController:SoundController;
      
      public function EntityAssetBundle(param1:String, param2:IEntityAssetBundleManager, param3:IEntityAppearanceDef)
      {
         this.appearance = param3;
         this._eps = param2;
         super(param1,param2);
         if(!param3)
         {
            throw new ArgumentError("EntityAssetBundle no appearance for [" + this + "]");
         }
      }
      
      override public function toString() : String
      {
         return "ENTITY=" + (!!this.appearance ? this.appearance.id : "nothing");
      }
      
      override protected function _handleUnload() : void
      {
         super._handleUnload();
         if(this._soundController)
         {
            this._soundController.cleanup();
            this._soundController = null;
         }
      }
      
      override public function cleanup() : void
      {
         if(this._soundController)
         {
            this._soundController.cleanup();
            this._soundController = null;
         }
         super.cleanup();
      }
      
      override protected function handleGroupComplete() : void
      {
         if(this.withSounds)
         {
            this._loadSounds();
         }
      }
      
      private function _loadSounds() : void
      {
         if(!this._slr && !this._slr.library)
         {
            return;
         }
         var _loc1_:String = "preload_" + this;
         this._soundController = new SoundController(_loc1_,this._eps.soundDriver,this.soundControllerHandler,logger);
         this._soundController.library = this._slr.library;
      }
      
      private function soundControllerHandler(param1:SoundController) : void
      {
         this._slr = this._slr;
      }
      
      public function load() : void
      {
         var eclazz:IEntityClassDef = null;
         eclazz = this.appearance.entityClass;
         try
         {
            if(this.appearance.animsUrl)
            {
               this._alr = _resman.getResource(this.appearance.animsUrl,IsoAnimLibraryResource,_group) as IsoAnimLibraryResource;
            }
         }
         catch(e:Error)
         {
            logger.error("animsUrl [" + appearance.animsUrl + "] was invalid");
            throw e;
         }
         try
         {
            if(this.appearance.vfxUrl)
            {
               this._vlr = _resman.getResource(this.appearance.vfxUrl,IsoVfxLibraryResource,_group) as IsoVfxLibraryResource;
            }
         }
         catch(e:Error)
         {
            logger.error("vfxUrl [" + appearance.vfxUrl + "] was invalid");
            throw e;
         }
         try
         {
            if(this.appearance.soundsUrl)
            {
               this._slr = _resman.getResource(this.appearance.soundsUrl,SoundLibraryResource,_group) as SoundLibraryResource;
            }
         }
         catch(e:Error)
         {
            logger.error("soundsUrl [" + appearance.soundsUrl + "] was invalid");
            throw e;
         }
         try
         {
            if(eclazz.propAnimUrl)
            {
               this._propAnimClipResource = _resman.getResource(eclazz.propAnimUrl,AnimClipResource,_group) as AnimClipResource;
            }
         }
         catch(e:Error)
         {
            logger.error("propAnimUrl [" + eclazz.propAnimUrl + "] was invalid");
            throw e;
         }
         this._loadIcon(EntityIconType.INIT_ORDER,_resman,_group);
         this._loadIcon(EntityIconType.INIT_ACTIVE,_resman,_group);
         this._loadShadow(_resman,_group);
         this._goAnimationRes = _resman.getResource("common/battle/vfx/go_spear/go_spear.clip",AnimClipResource,_group) as AnimClipResource;
         resman.getResource("common/ability/icon/icon_no_special.png",BitmapResource,_group);
      }
      
      public function loadSpeechBubble() : Boolean
      {
         if(this._speechBubbleRes)
         {
            return false;
         }
         var _loc1_:String = this.appearance.getIconUrl(EntityIconType.ROSTER);
         if(_loc1_)
         {
            this._speechBubbleRes = _resman.getResource(_loc1_,BitmapResource,_group) as BitmapResource;
            return true;
         }
         return false;
      }
      
      public function loadPortrait() : Boolean
      {
         if(this._portraitRes)
         {
            return false;
         }
         if(this.appearance.portraitUrl)
         {
            this._portraitRes = _resman.getResource(this.appearance.portraitUrl,AnimClipResource,_group) as AnimClipResource;
            return true;
         }
         return false;
      }
      
      public function loadVersus() : Boolean
      {
         if(this._versusRes)
         {
            return false;
         }
         if(this.appearance.versusPortraitUrl)
         {
            this._versusRes = _resman.getResource(this.appearance.versusPortraitUrl,BitmapResource,_group) as BitmapResource;
            return true;
         }
         return false;
      }
      
      private function _loadShadow(param1:IResourceManager, param2:IResourceGroup) : void
      {
         var _loc3_:IEntityClassDef = this.appearance.entityClass;
         if(_loc3_.disableShadow)
         {
            return;
         }
         var _loc4_:String = _loc3_.shadowUrl;
         if(!_loc4_)
         {
            if(_loc3_.bounds.width == 1 && _loc3_.bounds.length == 2)
            {
               _loc4_ = "common/battle/tile/two_tile_shadow.png";
            }
            else if(_loc3_.bounds.width == 2)
            {
               _loc4_ = "common/battle/tile/four_tile_shadow.png";
            }
            else
            {
               _loc4_ = "common/battle/tile/one_tile_shadow.png";
            }
         }
         if(_loc4_)
         {
            this._shadowBitmapResource = param1.getResource(_loc4_,BitmapResource,param2) as BitmapResource;
         }
      }
      
      private function _loadIcon(param1:EntityIconType, param2:IResourceManager, param3:IResourceGroup) : void
      {
         var _loc4_:String = this.appearance.getIconUrl(param1);
         if(_loc4_)
         {
            param2.getResource(_loc4_,BitmapResource,param3);
         }
      }
      
      public function preloadAbilityDef(param1:IBattleAbilityDef) : IAbilityAssetBundle
      {
         return this._eps.abilityAssetBundleManager.preloadAbilityDef(param1,this);
      }
      
      public function preloadAbilityDefById(param1:String) : IAbilityAssetBundle
      {
         return this._eps.abilityAssetBundleManager.preloadAbilityDefById(param1,this);
      }
      
      public function get alr() : IResource
      {
         return this._alr;
      }
      
      public function get vlr() : IResource
      {
         return this._vlr;
      }
      
      public function get slr() : IResource
      {
         return this._slr;
      }
      
      public function get propAnimClipResource() : IResource
      {
         return this._propAnimClipResource;
      }
      
      public function get shadowBitmapResource() : IResource
      {
         return this._shadowBitmapResource;
      }
      
      public function get goAnimationRes() : IResource
      {
         return this._goAnimationRes;
      }
      
      public function get speechBubbleRes() : IResource
      {
         return this._speechBubbleRes;
      }
      
      public function get portraitRes() : IResource
      {
         return this._portraitRes;
      }
   }
}
