package game.gui.battle.initiative
{
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.model.IEntity;
   import engine.gui.GuiUtil;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.text.TextField;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiInitiativeOrder extends GuiBase
   {
       
      
      public var frames:Vector.<GuiInitiativeOrderFrame>;
      
      public var lastX:Number = 0;
      
      public var textRound:TextField;
      
      private var _interact:IBattleEntity;
      
      public var selectedFrame:GuiInitiativeOrderFrame;
      
      private var startingParent:Sprite;
      
      private var initiative:GuiInitiative;
      
      public function GuiInitiativeOrder()
      {
         this.frames = new Vector.<GuiInitiativeOrderFrame>();
         super();
      }
      
      public function init(param1:IGuiContext, param2:Vector.<IEntity>, param3:GuiInitiative) : void
      {
         var _loc6_:GuiInitiativeOrderFrame = null;
         initGuiBase(param1);
         this.initiative = param3;
         this.startingParent = parent as Sprite;
         var _loc4_:int = 0;
         while(_loc4_ < numChildren)
         {
            _loc6_ = getChildAt(_loc4_) as GuiInitiativeOrderFrame;
            if(_loc6_)
            {
               this.frames.push(_loc6_);
               _loc6_.init(param1,this.frames.length,true,param2);
               _loc6_.addEventListener(GuiInitiativeOrderFrame.HIGHLIGHTED,this.frameHighlightedHandler);
            }
            _loc4_++;
         }
         if(this.frames.length != 11)
         {
            throw new ArgumentError("Missing order frames");
         }
         var _loc5_:int = 0;
         while(_loc5_ < this.frames.length)
         {
            this.frames[_loc5_].index = this.frames.length - this.frames[_loc5_].index;
            _loc5_++;
         }
         this.frames.reverse();
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiInitiativeOrderFrame = null;
         for each(_loc1_ in this.frames)
         {
            _loc1_.removeEventListener(GuiInitiativeOrderFrame.HIGHLIGHTED,this.frameHighlightedHandler);
            _loc1_.cleanup();
         }
         this.frames = null;
         this.selectedFrame = null;
         super.cleanupGuiBase();
      }
      
      private function hideAllFrames() : void
      {
         var _loc1_:GuiInitiativeOrderFrame = null;
         for each(_loc1_ in this.frames)
         {
            _loc1_.visible = false;
            GuiUtil.updateDisplayList(_loc1_,this);
         }
      }
      
      public function clearHighlights() : void
      {
         var _loc2_:GuiInitiativeOrderFrame = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.frames.length)
         {
            _loc2_ = this.frames[_loc1_];
            _loc2_.hilighted = false;
            _loc1_++;
         }
      }
      
      public function setOrderEntities(param1:Vector.<IBattleEntity>, param2:int) : void
      {
         var _loc3_:GuiInitiativeOrderFrame = null;
         var _loc6_:GuiInitiativeOrderFrame = null;
         var _loc7_:int = 0;
         var _loc8_:IBattleEntity = null;
         this._interact = null;
         var _loc4_:IBattleEntity = !!param1.length ? param1[param1.length - 1] : null;
         this.lastX = 0;
         var _loc5_:int = 0;
         while(_loc5_ < this.frames.length)
         {
            _loc6_ = this.frames[_loc5_];
            _loc7_ = _loc5_ + param2;
            if(_loc7_ >= param1.length)
            {
               if(_loc6_.visible)
               {
                  _loc6_.visible = false;
                  GuiUtil.updateDisplayList(_loc6_,this);
                  _loc6_.entity = null;
               }
            }
            else
            {
               _loc8_ = param1[_loc7_];
               _loc3_ = _loc6_;
               _loc6_.willTweenIn = _loc8_ == _loc4_;
               this.lastX = _loc6_.x;
               _loc6_.visible = true;
               GuiUtil.updateDisplayList(_loc6_,this);
               _loc6_.entity = _loc8_;
               _loc6_.updateBuffs(_loc8_.effects);
            }
            _loc5_++;
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function set interact(param1:IBattleEntity) : void
      {
         var _loc3_:GuiInitiativeOrderFrame = null;
         if(param1 == this._interact)
         {
            return;
         }
         this._interact = param1;
         this.selectedFrame = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.frames.length)
         {
            _loc3_ = this.frames[_loc2_];
            _loc3_.hilighted = _loc3_.entity == param1;
            if(_loc3_.hilighted && Boolean(param1))
            {
               this.selectedFrame = _loc3_;
            }
            _loc2_++;
         }
      }
      
      private function frameHighlightedHandler(param1:Event) : void
      {
         var _loc2_:GuiInitiativeOrderFrame = param1.target as GuiInitiativeOrderFrame;
         if(!this.initiative.handleInitiativeInteract(_loc2_.entity))
         {
            return;
         }
         this.interact = _loc2_.entity;
      }
      
      public function get interact() : IBattleEntity
      {
         return this._interact;
      }
      
      public function getPositionForEntity(param1:IBattleEntity) : Point
      {
         var _loc2_:GuiInitiativeOrderFrame = null;
         for each(_loc2_ in this.frames)
         {
            if(_loc2_.entity == param1)
            {
               return _loc2_.getCenterPosition_g();
            }
         }
         return null;
      }
   }
}
