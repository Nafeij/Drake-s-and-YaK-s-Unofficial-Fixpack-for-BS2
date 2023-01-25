package game.gui.page
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Strong;
   import com.stoicstudio.platform.PlatformFlash;
   import engine.core.logging.ILogger;
   import engine.core.render.MatteHelper;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.landscape.def.ILandscapeDef;
   import engine.landscape.def.ILandscapeLayerDef;
   import engine.landscape.def.ILandscapeSpriteDef;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import engine.scene.model.Scene;
   import engine.scene.view.SceneViewController;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   import game.gui.GuiIconSlotEvent;
   import game.gui.IGuiCharacterIconSlot;
   
   public class TravelPageTalkies
   {
      
      public static var mcClazzTalkieLeft:Class;
      
      public static var mcClazzTalkieRight:Class;
      
      public static var PROTOTYPE_TALKIE_MATTE:Boolean;
      
      public static const TALK_PREFIX:String = "talk_";
       
      
      private var matteHelper:MatteHelper;
      
      private var travelPage:TravelPage;
      
      private var scenePage:ScenePage;
      
      private var config:GameConfig;
      
      private var saga:Saga;
      
      public var initReady:Boolean;
      
      private var _enableClick:Boolean;
      
      private var controller:SceneViewController;
      
      public var logger:ILogger;
      
      private var anchor2talkies:Dictionary;
      
      private var entity2anchors:Dictionary;
      
      public function TravelPageTalkies(param1:TravelPage)
      {
         this.anchor2talkies = new Dictionary();
         this.entity2anchors = new Dictionary();
         super();
         this.travelPage = param1;
         this.scenePage = param1.scenePage;
         this.config = param1.config;
         this.logger = this.config.logger;
         if(PROTOTYPE_TALKIE_MATTE)
         {
            this.matteHelper = new MatteHelper(param1,this.scenePage.scene.camera);
            this.matteHelper.visible = true;
            this.matteHelper.enabled = true;
         }
      }
      
      public function resizeHandler() : void
      {
         if(this.matteHelper)
         {
            this.matteHelper.matteChangedHandler(null);
            this.matteHelper.bringToFront();
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in this.anchor2talkies)
         {
            this.updateAnchor(_loc2_);
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:IGuiCharacterIconSlot = null;
         if(this.saga)
         {
            this.saga.removeEventListener(SagaEvent.EVENT_TALK,this.sagaTalkHandler);
            this.saga = null;
         }
         for each(_loc1_ in this.anchor2talkies)
         {
            this._cleanupTalkie(_loc1_);
         }
         this.anchor2talkies = null;
         this.entity2anchors = null;
      }
      
      private function updateAnchor(param1:String) : void
      {
         var _loc4_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:MovieClip = null;
         var _loc2_:IGuiCharacterIconSlot = this.anchor2talkies[param1];
         var _loc3_:Point = this.scenePage.view.landscapeView.getAnchorPoint(param1);
         if(_loc3_)
         {
            _loc4_ = this.scenePage.view.landscapeView.localToGlobal(_loc3_);
            _loc5_ = this.travelPage.globalToLocal(_loc4_);
            _loc6_ = _loc2_ as MovieClip;
            _loc6_.x = _loc5_.x;
            _loc6_.y = _loc5_.y;
         }
         _loc2_.guiIconMouseEnabled = this._enableClick;
      }
      
      internal function checkForTalkies() : void
      {
         var _loc3_:IEntityDef = null;
         var _loc4_:IVariable = null;
         this.logger.info("TravelPageTalkies.checkForTalkie START");
         if(!this.saga || !this.saga.caravan)
         {
            this.logger.info("TravelPageTalkies.checkForTalkie (!saga || !saga.caravan)");
            return;
         }
         if(!this.scenePage || !this.scenePage.scene || !this.scenePage.scene._def)
         {
            this.logger.info("TravelPageTalkies.checkForTalkie (!scenePage || !scenePage.scene || !scenePage.scene._def)");
            return;
         }
         var _loc1_:IEntityListDef = this.saga.caravan.legend.roster;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.numEntityDefs)
         {
            _loc3_ = _loc1_.getEntityDef(_loc2_);
            _loc4_ = _loc3_.vars.fetch("talk",null);
            if(_loc4_)
            {
               if(_loc4_.asInteger != 0)
               {
                  if(this.showTalkie(_loc3_))
                  {
                     this.saga.handleCampTalkieSeen(_loc3_.id);
                  }
               }
               else
               {
                  this.hideTalkie(_loc3_);
               }
            }
            _loc2_++;
         }
      }
      
      private function findNextAnchor(param1:IEntityDef) : String
      {
         var _loc7_:ILandscapeLayerDef = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:ILandscapeSpriteDef = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:Number = NaN;
         var _loc2_:Array = [];
         var _loc3_:String = TALK_PREFIX + param1.id;
         var _loc4_:Scene = this.scenePage.scene;
         if(!_loc4_._def)
         {
            return null;
         }
         var _loc5_:ILandscapeDef = _loc4_._def.landscape;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_.numLayerDefs)
         {
            _loc7_ = _loc5_.getLayerDef(_loc6_);
            _loc8_ = _loc7_.getNameId();
            _loc9_ = 0;
            while(_loc9_ < _loc7_.numSprites)
            {
               _loc10_ = _loc7_.getSpriteAt(_loc9_);
               if(_loc10_.isAnchor)
               {
                  _loc11_ = _loc10_.getNameId();
                  if(_loc11_.indexOf(TALK_PREFIX) == 0)
                  {
                     _loc12_ = _loc8_ + "." + _loc11_;
                     if(!(_loc12_ in this.anchor2talkies))
                     {
                        if(_loc11_.indexOf(_loc3_) == 0)
                        {
                           return _loc12_;
                        }
                        _loc2_.push(_loc12_);
                     }
                  }
               }
               _loc9_++;
            }
            _loc6_++;
         }
         if(_loc2_.length > 0)
         {
            _loc13_ = MathUtil.randomInt(0,_loc2_.length - 1);
            return _loc2_[_loc13_];
         }
         return null;
      }
      
      private function createTalkie(param1:IEntityDef, param2:String) : IGuiCharacterIconSlot
      {
         if(!param1)
         {
            return null;
         }
         var _loc3_:Class = null;
         if(param2.indexOf("_left") >= 0)
         {
            _loc3_ = mcClazzTalkieLeft;
         }
         else
         {
            _loc3_ = mcClazzTalkieRight;
         }
         var _loc4_:IGuiCharacterIconSlot = !!_loc3_ ? new _loc3_() as IGuiCharacterIconSlot : null;
         if(_loc4_)
         {
            _loc4_.movieClip.name = "talkie_" + param1.id;
            _loc4_.init(this.config.gameGuiContext);
            _loc4_.dragEnabled = false;
            _loc4_.setCharacter(param1,EntityIconType.INIT_ORDER);
            _loc4_.addEventListener(GuiIconSlotEvent.CLICKED,this.talkieClickHandler);
            _loc4_.guiIconMouseEnabled = this._enableClick;
         }
         return _loc4_;
      }
      
      private function talkieClickHandler(param1:GuiIconSlotEvent) : void
      {
         if(!this.saga)
         {
            return;
         }
         if(!this.scenePage || this.scenePage.wiping || !this.scenePage.scene || !this.scenePage.scene.ready)
         {
            return;
         }
         var _loc2_:IEntityDef = (param1.target as IGuiCharacterIconSlot).character;
         var _loc3_:String = String(_loc2_.id);
         var _loc4_:IVariable = _loc2_.vars.fetch(SagaVar.VAR_UNIT_TALK,null);
         _loc4_.asAny = 0;
         this.saga.triggerTalk(_loc3_);
      }
      
      private function attachTalkieToAnchor(param1:IEntityDef, param2:String) : Boolean
      {
         var _loc3_:IGuiCharacterIconSlot = this.createTalkie(param1,param2);
         if(!_loc3_)
         {
            return false;
         }
         var _loc4_:MovieClip = _loc3_ as MovieClip;
         this.travelPage.addChild(_loc4_);
         _loc4_.scaleX = _loc4_.scaleY = 0.2;
         TweenMax.to(_loc4_,0.3,{
            "scaleX":1,
            "scaleY":1,
            "ease":Strong.easeOut
         });
         this.anchor2talkies[param2] = _loc3_;
         this.entity2anchors[param1.id] = param2;
         this.updateAnchor(param2);
         return true;
      }
      
      private function showTalkie(param1:IEntityDef) : Boolean
      {
         this.logger.info("TravelPageTalkies.showTalkie e=" + param1);
         if(!param1)
         {
            return false;
         }
         if(param1.id in this.entity2anchors)
         {
            return false;
         }
         var _loc2_:String = this.findNextAnchor(param1);
         if(!_loc2_)
         {
            return false;
         }
         return this.attachTalkieToAnchor(param1,_loc2_);
      }
      
      private function hideTalkie(param1:IEntityDef) : void
      {
         var _loc3_:IGuiCharacterIconSlot = null;
         var _loc2_:String = String(this.entity2anchors[param1.id]);
         if(_loc2_)
         {
            _loc3_ = this.anchor2talkies[_loc2_];
            this._cleanupTalkie(_loc3_);
            delete this.anchor2talkies[_loc2_];
         }
         delete this.entity2anchors[param1.id];
      }
      
      private function _cleanupTalkie(param1:IGuiCharacterIconSlot) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:MovieClip = param1 as MovieClip;
         if(_loc2_.parent)
         {
            _loc2_.parent.removeChild(_loc2_);
         }
         param1.removeEventListener(GuiIconSlotEvent.CLICKED,this.talkieClickHandler);
         param1.cleanup();
      }
      
      public function doInitReady() : void
      {
         if(this.initReady)
         {
            return;
         }
         this.logger.info("TravelPageTalkies.doInitReady");
         this.initReady = true;
         this.controller = this.scenePage.controller;
         this.saga = this.config.saga;
         if(this.saga)
         {
            this.logger.info("TravelPageTalkies.doInitReady saga.camped=" + this.saga.camped);
            if(this.saga.camped)
            {
               this.saga.addEventListener(SagaEvent.EVENT_TALK,this.sagaTalkHandler);
               this.sagaTalkHandler(null);
            }
         }
      }
      
      private function sagaTalkHandler(param1:Event) : void
      {
         this.checkForTalkies();
      }
      
      public function get enableClick() : Boolean
      {
         return this._enableClick;
      }
      
      public function set enableClick(param1:Boolean) : void
      {
         if(this._enableClick == param1)
         {
            return;
         }
         this._enableClick = param1;
         this.update(0);
      }
      
      public function gpPointerHandler() : void
      {
         var _loc7_:String = null;
         var _loc8_:IGuiCharacterIconSlot = null;
         if(!this.controller || !this.controller.gpPointerAllowHover)
         {
            return;
         }
         if(!this.controller.gpPointerEnabled)
         {
            return;
         }
         var _loc1_:Number = this.controller.gpPointerX;
         var _loc2_:Number = this.controller.gpPointerY;
         var _loc3_:Number = PlatformFlash.stage.stageWidth;
         var _loc4_:Number = PlatformFlash.stage.stageHeight;
         var _loc5_:Number = _loc3_ * (_loc1_ + 1) / 2;
         var _loc6_:Number = _loc4_ * (_loc2_ + 1) / 2;
         for(_loc7_ in this.anchor2talkies)
         {
            _loc8_ = this.anchor2talkies[_loc7_];
            if(_loc8_.movieClip.hitTestPoint(_loc5_,_loc6_,true))
            {
               this.controller.hoverTalkie = _loc8_;
               return;
            }
         }
         this.controller.hoverTalkie = null;
      }
      
      public function talkieNextPrev(param1:IGuiCharacterIconSlot, param2:Point, param3:Boolean) : IGuiCharacterIconSlot
      {
         var _loc4_:Point = null;
         if(param2)
         {
            _loc4_ = this.travelPage.globalToLocal(param2);
         }
         if(param3)
         {
            return this.talkie_next(param1,param2);
         }
         return this.talkie_prev(param1,param2);
      }
      
      public function talkie_next(param1:IGuiCharacterIconSlot, param2:Point) : IGuiCharacterIconSlot
      {
         var _loc5_:IGuiCharacterIconSlot = null;
         var _loc8_:IGuiCharacterIconSlot = null;
         var _loc9_:String = null;
         var _loc10_:IGuiCharacterIconSlot = null;
         var _loc11_:MovieClip = null;
         var _loc12_:Point = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc3_:Number = Number.MAX_VALUE;
         var _loc4_:Number = Number.MAX_VALUE;
         var _loc6_:Number = Number.MAX_VALUE;
         var _loc7_:Number = Number.MAX_VALUE;
         for(_loc9_ in this.anchor2talkies)
         {
            _loc10_ = this.anchor2talkies[_loc9_];
            _loc11_ = _loc10_.movieClip;
            if(!(!_loc11_.visible || !_loc10_.character || _loc10_ == param1))
            {
               _loc12_ = _loc10_.talkieCenterPoint_g;
               _loc13_ = _loc12_.x;
               _loc14_ = _loc12_.y;
               if(_loc13_ < _loc3_ || _loc13_ == _loc3_ && (!_loc5_ || _loc14_ < _loc4_))
               {
                  _loc4_ = _loc14_;
                  _loc3_ = _loc13_;
                  _loc5_ = _loc10_;
               }
               if(param2)
               {
                  if(_loc13_ > param2.x || _loc13_ == param2.x && _loc14_ > param2.y)
                  {
                     if(_loc13_ < _loc6_ || _loc13_ == _loc6_ && (!_loc8_ || _loc14_ < _loc7_))
                     {
                        _loc6_ = _loc13_;
                        _loc7_ = _loc14_;
                        _loc8_ = _loc10_;
                     }
                  }
               }
            }
         }
         return !!_loc8_ ? _loc8_ : _loc5_;
      }
      
      public function talkie_prev(param1:IGuiCharacterIconSlot, param2:Point) : IGuiCharacterIconSlot
      {
         var _loc5_:IGuiCharacterIconSlot = null;
         var _loc8_:IGuiCharacterIconSlot = null;
         var _loc9_:String = null;
         var _loc10_:IGuiCharacterIconSlot = null;
         var _loc11_:MovieClip = null;
         var _loc12_:Point = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc3_:Number = -Number.MAX_VALUE;
         var _loc4_:Number = -Number.MAX_VALUE;
         var _loc6_:Number = -Number.MAX_VALUE;
         var _loc7_:Number = -Number.MAX_VALUE;
         for(_loc9_ in this.anchor2talkies)
         {
            _loc10_ = this.anchor2talkies[_loc9_];
            _loc11_ = _loc10_.movieClip;
            if(!(!_loc11_.visible || !_loc10_.character || _loc10_ == param1))
            {
               _loc12_ = _loc10_.talkieCenterPoint_g;
               _loc13_ = _loc12_.x;
               _loc14_ = _loc12_.y;
               if(_loc13_ > _loc3_ || _loc13_ == _loc3_ && (!_loc5_ || _loc14_ > _loc4_))
               {
                  _loc4_ = _loc14_;
                  _loc3_ = _loc13_;
                  _loc5_ = _loc10_;
               }
               if(param2)
               {
                  if(_loc13_ < param2.x || _loc13_ == param2.x && _loc14_ < param2.y)
                  {
                     if(_loc13_ > _loc6_ || _loc13_ == _loc6_ && (!_loc8_ || _loc14_ > _loc7_))
                     {
                        _loc6_ = _loc13_;
                        _loc7_ = _loc14_;
                        _loc8_ = _loc10_;
                     }
                  }
               }
            }
         }
         return !!_loc8_ ? _loc8_ : _loc5_;
      }
   }
}
