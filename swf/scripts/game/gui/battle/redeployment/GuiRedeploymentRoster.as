package game.gui.battle.redeployment
{
   import com.greensock.TweenMax;
   import engine.battle.board.model.BattleBoard_Redeploy;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.sim.IBattleParty;
   import engine.core.util.ArrayUtil;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import game.gui.GuiCharacterIconSlots;
   import game.gui.IGuiCharacterIconSlot;
   import game.gui.IGuiContext;
   import game.gui.IGuiIconSlot;
   import game.gui.battle.GuiBattleInfo;
   import game.gui.page.BattleHudPage;
   
   public class GuiRedeploymentRoster extends GuiCharacterIconSlots
   {
      
      public static const ROSTER_DISPLAY_CHANGED:String = "GuiRedeploymentRoster.ROSTER_DISPLAY_CHANGED";
      
      public static const ROSTER_DISPLAY_EXPANDED:String = "GuiRedeploymentRoster.ROSTER_DISPLAY_EXPANDED";
       
      
      private var MAX_ROWS:int = 3;
      
      private var MAX_COLUMNS:int = 2147483647;
      
      public var redeploymentEntityFrameClazz:Class;
      
      public var roster:IEntityListDef;
      
      private var _battleParty:IBattleParty;
      
      private var _bbRedeploy:BattleBoard_Redeploy;
      
      private var _backgroundMC:MovieClip;
      
      private var _rosterTitle:MovieClip;
      
      private var _infoRosterClosedPosition:Point;
      
      private var _infoRosterOpenPosition:Point;
      
      private var _rosterTitleClosedPosition:Point;
      
      private var _rosterTitleOpenPosition:Point;
      
      private var _info:GuiBattleInfo;
      
      private var _context:IGuiContext;
      
      private var _numIconsForRow:Vector.<int>;
      
      private var _onExpanded:Function;
      
      private var _rosterDisplayed:Boolean = true;
      
      private var _iconPositions:Vector.<Point>;
      
      private var _iconHeight:Number;
      
      private var _iconWidth:Number;
      
      private var _iconHeightCount:int;
      
      private var _iconWidthCount:int;
      
      private var _xPackingOffset:Number = -30;
      
      private var _yPackingOffset:Number = -25;
      
      private var _xBuffer:Number = 18;
      
      private var _yBuffer:Number = 15;
      
      public function GuiRedeploymentRoster()
      {
         this._infoRosterClosedPosition = new Point();
         this._infoRosterOpenPosition = new Point();
         this._rosterTitleClosedPosition = new Point();
         this._rosterTitleOpenPosition = new Point();
         super();
      }
      
      public function initRoster(param1:IGuiContext, param2:BattleHudPage, param3:BattleBoard_Redeploy, param4:GuiBattleInfo, param5:MovieClip) : void
      {
         this._infoRosterClosedPosition.x = param4.x;
         this._infoRosterClosedPosition.y = param4.y;
         this._info = param4;
         this._context = param1;
         this.roster = param1.iSaga.roster;
         this._bbRedeploy = param3;
         this._rosterTitle = param5;
         this._battleParty = param2.board.getPartyById("0") as IBattleParty;
         super.init(param1);
         this.initBackground();
         this.initCharacterIconSlots(param1,param2.width,param2.height);
         this._rosterTitleClosedPosition.x = this._rosterTitle.x;
         this._rosterTitleClosedPosition.y = this._rosterTitle.y;
         this._rosterTitleOpenPosition.x = this._rosterTitle.x;
         this._rosterTitleOpenPosition.y = this._rosterTitleClosedPosition.y - this._backgroundMC.height;
      }
      
      public function numIconColumnsForRow(param1:int) : int
      {
         return this._numIconsForRow[param1];
      }
      
      public function get numIconRows() : int
      {
         return this._iconHeightCount;
      }
      
      private function initBackground() : void
      {
         this._backgroundMC = this["background"] as MovieClip;
         if(!this._backgroundMC)
         {
            this._backgroundMC = this.getChildByName("background") as MovieClip;
         }
      }
      
      private function initCharacterIconSlots(param1:IGuiContext, param2:Number, param3:Number) : void
      {
         var _loc5_:IGuiCharacterIconSlot = null;
         var _loc6_:IEntityDef = null;
         var _loc7_:IBattleEntity = null;
         var _loc8_:* = false;
         var _loc4_:int = 0;
         while(_loc4_ < this.roster.numCombatants)
         {
            _loc5_ = new this.redeploymentEntityFrameClazz() as IGuiCharacterIconSlot;
            _loc5_.init(param1);
            _loc6_ = this.roster.getCombatantAt(_loc4_);
            _loc5_.setCharacter(_loc6_,EntityIconType.INIT_ORDER);
            iconSlots.push(_loc5_);
            addChild(_loc5_ as DisplayObject);
            _loc7_ = this._battleParty.getMemberByDefId(_loc6_.id);
            _loc8_ = _loc7_ != null;
            if(!_loc8_)
            {
               _loc7_ = this._bbRedeploy.getBattleEntity(_loc6_);
            }
            _loc5_.iconEnabled = true;
            _loc4_++;
         }
         this.updateRosterIcons();
      }
      
      public function getGuiIconFromRosterIndexPosition(param1:int, param2:int) : IGuiIconSlot
      {
         var _loc3_:int = 0;
         _loc3_ = this.numIconColumnsForRow(0);
         var _loc4_:int = _loc3_ * param1 + param2;
         if(_loc4_ >= numSlots)
         {
            return null;
         }
         return iconSlots[_loc4_];
      }
      
      public function resizeHandler(param1:Number, param2:Number, param3:MovieClip) : void
      {
         param3.enabled = false;
         if(!iconSlots || iconSlots.length < 1)
         {
            return;
         }
         if(!this._iconPositions)
         {
            this.buildIconPositions(param1,param2);
         }
         var _loc4_:int = 0;
         while(_loc4_ < iconSlots.length)
         {
            iconSlots[_loc4_].movieClip.x = this._iconPositions[_loc4_].x;
            iconSlots[_loc4_].movieClip.y = this._iconPositions[_loc4_].y;
            _loc4_++;
         }
         var _loc5_:Number = this._iconHeightCount * this._iconHeight;
         var _loc6_:Number = this._iconWidthCount > iconSlots.length ? this._iconWidth * iconSlots.length : this._iconWidth * this._iconWidthCount;
         if(this._backgroundMC)
         {
            this._backgroundMC.width = _loc6_ + this._xBuffer;
            this._backgroundMC.height = _loc5_ + this._yBuffer;
            param3.width = this._backgroundMC.width + 40;
            param3.height = this._backgroundMC.height + 40;
         }
         this._infoRosterOpenPosition.x = this._infoRosterClosedPosition.x;
         this._infoRosterOpenPosition.y = this._infoRosterClosedPosition.y - _loc5_ - 14;
         this._rosterTitleOpenPosition.x = this._rosterTitle.x;
         this._rosterTitleOpenPosition.y = this._rosterTitleClosedPosition.y - this._backgroundMC.height;
      }
      
      private function buildIconPositions(param1:Number, param2:Number) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Point = null;
         var _loc3_:MovieClip = iconSlots[0].movieClip;
         if(!_loc3_)
         {
            return;
         }
         if(this._iconPositions)
         {
            this._iconPositions.length = 0;
            this._iconPositions = null;
         }
         if(this._numIconsForRow)
         {
            this._numIconsForRow.length = 0;
            this._numIconsForRow = null;
         }
         this.MAX_ROWS = Math.floor((param2 + this.y - 50) / _loc3_.height);
         this._iconPositions = new Vector.<Point>();
         this._numIconsForRow = new Vector.<int>();
         this._iconWidth = _loc3_.width + this._xPackingOffset;
         this._iconHeight = _loc3_.height + this._yPackingOffset;
         this._iconWidthCount = Math.min(Math.floor(this._info.movieClip.width / this._iconWidth),this.MAX_COLUMNS);
         this._iconHeightCount = Math.min(Math.ceil(iconSlots.length / this._iconWidthCount),this.MAX_ROWS);
         var _loc4_:int = 0;
         while(_loc4_ < this._iconHeightCount)
         {
            _loc5_ = _loc4_ * this._iconWidthCount;
            _loc6_ = _loc4_ - this._iconHeightCount;
            _loc7_ = 0;
            _loc8_ = 0;
            while(_loc8_ < this._iconWidthCount && _loc5_ + _loc8_ < iconSlots.length)
            {
               _loc9_ = new Point();
               _loc9_.x = _loc8_ * this._iconWidth + this._iconWidth / 2 + 10;
               _loc9_.y = _loc6_ * this._iconHeight - 5;
               _loc7_ += 1;
               this._iconPositions.push(_loc9_);
               _loc8_++;
            }
            this._numIconsForRow.push(_loc7_);
            _loc4_++;
         }
      }
      
      public function updateRosterIcons() : void
      {
         var _loc2_:IGuiIconSlot = null;
         var _loc3_:IGuiIconSlot = null;
         var _loc4_:IGuiCharacterIconSlot = null;
         var _loc5_:IBattleEntity = null;
         var _loc6_:int = 0;
         var _loc1_:Vector.<IGuiIconSlot> = new Vector.<IGuiIconSlot>();
         for each(_loc2_ in iconSlots)
         {
            _loc4_ = _loc2_ as IGuiCharacterIconSlot;
            if(_loc4_)
            {
               _loc4_.setCharacter(_loc4_.character,EntityIconType.INIT_ORDER);
               _loc5_ = this._battleParty.getMemberByDefId(_loc4_.character.id);
               if(_loc5_)
               {
                  _loc4_.iconEnabled = false;
               }
               else
               {
                  _loc4_.iconEnabled = true;
                  _loc5_ = this._bbRedeploy.getBattleEntity(_loc4_.character);
                  if(!_loc5_)
                  {
                     _loc5_ = this._bbRedeploy.board.getEntityByDefId(_loc4_.character.id,null,true);
                  }
               }
               if(Boolean(_loc5_) && !_loc5_.alive)
               {
                  _loc1_.push(_loc2_);
                  _loc4_.iconEnabled = false;
               }
            }
         }
         for each(_loc3_ in _loc1_)
         {
            ArrayUtil.removeAt(iconSlots,iconSlots.indexOf(_loc3_));
            iconSlots.push(_loc3_);
         }
         if(Boolean(this._iconPositions) && this._iconPositions.length > 0)
         {
            _loc6_ = 0;
            while(_loc6_ < iconSlots.length)
            {
               iconSlots[_loc6_].movieClip.x = this._iconPositions[_loc6_].x;
               iconSlots[_loc6_].movieClip.y = this._iconPositions[_loc6_].y;
               _loc6_++;
            }
         }
      }
      
      public function toggleRoster() : void
      {
         this.rosterDisplayed = !this.rosterDisplayed;
      }
      
      public function get rosterDisplayed() : Boolean
      {
         return this._rosterDisplayed;
      }
      
      public function set rosterDisplayed(param1:Boolean) : void
      {
         if(param1 == this._rosterDisplayed)
         {
            return;
         }
         this._rosterDisplayed = param1;
         if(this._rosterDisplayed)
         {
            this.expand(1);
         }
         else
         {
            this.collapse();
         }
         dispatchEvent(new Event(GuiRedeploymentRoster.ROSTER_DISPLAY_CHANGED));
      }
      
      public function setRosterExpandedCallback(param1:Function) : void
      {
         this._onExpanded = param1;
      }
      
      override public function expand(param1:Number) : void
      {
         var i:int;
         var animationDuration:Number = param1;
         visible = true;
         this.killAllTweens();
         this._info.movieClip.x = this._infoRosterOpenPosition.x;
         this._info.movieClip.y = this._infoRosterOpenPosition.y;
         if(!this._backgroundMC)
         {
            return;
         }
         if(animationDuration == 0)
         {
            this.expandImmediate();
            return;
         }
         TweenMax.to(this._backgroundMC,animationDuration,{
            "y":0,
            "onComplete":function():void
            {
               dispatchEvent(new Event(GuiRedeploymentRoster.ROSTER_DISPLAY_EXPANDED));
            }
         });
         TweenMax.to(this._rosterTitle,animationDuration,{"y":this._rosterTitleOpenPosition.y});
         if(!this._iconPositions)
         {
            return;
         }
         i = 0;
         while(i < iconSlots.length && i < this._iconPositions.length)
         {
            TweenMax.to(iconSlots[i],0,{"y":0 + this._iconHeight * Math.floor(i / this._iconWidthCount)});
            TweenMax.to(iconSlots[i],animationDuration,{"y":this._iconPositions[i].y});
            i++;
         }
         if(this._onExpanded != null)
         {
            TweenMax.delayedCall(animationDuration,this._onExpanded);
         }
      }
      
      private function expandImmediate() : void
      {
         this._backgroundMC.y = 0;
         if(!this._iconPositions)
         {
            return;
         }
         var _loc1_:int = 0;
         while(_loc1_ < iconSlots.length && _loc1_ < this._iconPositions.length)
         {
            iconSlots[_loc1_].movieClip.y = this._iconPositions[_loc1_].y;
            _loc1_++;
         }
         this._rosterTitle.y = this._rosterTitleOpenPosition.y;
      }
      
      override public function collapse() : void
      {
         var duration:Number;
         var i:int;
         this.killAllTweens();
         this._info.setVisible(false);
         this._info.movieClip.x = this._infoRosterClosedPosition.x;
         this._info.movieClip.y = this._infoRosterClosedPosition.y;
         duration = 1;
         if(!this._backgroundMC)
         {
            return;
         }
         TweenMax.to(this._backgroundMC,duration,{
            "y":this._backgroundMC.height,
            "onComplete":function():void
            {
               visible = false;
            }
         });
         TweenMax.to(this._rosterTitle,duration,{"y":this._rosterTitleClosedPosition.y});
         if(!this._iconPositions)
         {
            return;
         }
         i = 0;
         while(i < iconSlots.length)
         {
            TweenMax.to(iconSlots[i],duration,{"y":Math.floor(i / this._iconWidthCount) * iconSlots[i].movieClip.height + this._yBuffer / 2});
            i++;
         }
      }
      
      private function collapseRosterTitle() : void
      {
         if(!this._rosterTitle)
         {
            return;
         }
         TweenMax.to(this._rosterTitle.mc,0.2,{
            "alpha":0,
            "y":this._backgroundMC.y - this._backgroundMC.height + this._rosterTitle.mc.height,
            "onComplete":this.cleanupRosterTitle
         });
      }
      
      private function cleanupRosterTitle() : void
      {
         if(!this._rosterTitle)
         {
            return;
         }
         this.removeChild(this._rosterTitle.mc);
         this._rosterTitle.cleanup();
         this._rosterTitle = null;
      }
      
      public function killAllTweens() : void
      {
         TweenMax.killTweensOf(this._backgroundMC);
         var _loc1_:int = 0;
         while(_loc1_ < this.iconSlots.length)
         {
            TweenMax.killTweensOf(iconSlots[_loc1_].movieClip);
            _loc1_++;
         }
         if(this._onExpanded != null)
         {
            TweenMax.killDelayedCallsTo(this._onExpanded);
         }
         if(this._rosterTitle)
         {
            TweenMax.killTweensOf(this._rosterTitle.mc);
         }
      }
      
      override public function cleanup() : void
      {
         this.killAllTweens();
         super.cleanup();
      }
   }
}
