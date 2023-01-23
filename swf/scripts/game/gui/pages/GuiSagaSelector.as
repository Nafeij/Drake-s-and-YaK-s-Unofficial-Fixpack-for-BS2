package game.gui.pages
{
   import engine.gui.GuiGpNav;
   import engine.gui.IGuiButton;
   import flash.events.Event;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.page.IGuiSagaSelector;
   import game.gui.page.IGuiSagaSelectorListener;
   
   public class GuiSagaSelector extends GuiBase implements IGuiSagaSelector
   {
       
      
      public var nav:GuiGpNav;
      
      public var buttons:Vector.<ButtonWithIndex>;
      
      public var listener:IGuiSagaSelectorListener;
      
      public function GuiSagaSelector()
      {
         var _loc2_:IGuiButton = null;
         this.buttons = new Vector.<ButtonWithIndex>();
         super();
         var _loc1_:int = 0;
         while(_loc1_ < this.numChildren)
         {
            _loc2_ = getChildAt(_loc1_) as ButtonWithIndex;
            if(_loc2_)
            {
               this.buttons.push(_loc2_);
            }
            _loc1_++;
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:ButtonWithIndex = null;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         for each(_loc1_ in this.buttons)
         {
            _loc1_.cleanup();
         }
         this.buttons = null;
         this.listener = null;
         super.cleanupGuiBase();
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaSelectorListener) : void
      {
         var _loc3_:ButtonWithIndex = null;
         super.initGuiBase(param1);
         this.listener = param2;
         this.nav = new GuiGpNav(param1,"ssel",this);
         for each(_loc3_ in this.buttons)
         {
            if(!this._extract_id_from_button(_loc3_))
            {
               logger.error("invalid button name " + _loc3_.name);
            }
            _loc3_.guiButtonContext = _loc3_;
            _loc3_.setDownFunction(this.buttonDownHandler);
            _loc3_.addEventListener(ButtonWithIndex.EVENT_STATE,this.buttonStateHandler);
            this.nav.add(_loc3_);
         }
         this.nav.activate();
      }
      
      public function update(param1:int) : void
      {
         if(this.nav)
         {
            this.nav.update(param1);
         }
      }
      
      private function buttonStateHandler(param1:Event) : void
      {
         var _loc3_:ButtonWithIndex = null;
         var _loc2_:ButtonWithIndex = param1.target as ButtonWithIndex;
         if(_loc2_.isHovering)
         {
            for each(_loc3_ in this.buttons)
            {
               _loc3_.setHovering(_loc3_ == _loc2_);
            }
            if(this.nav.isActivated)
            {
               this.nav.selected = _loc2_;
            }
         }
      }
      
      public function buttonDownHandler(param1:ButtonWithIndex) : void
      {
         var _loc2_:String = this._extract_id_from_button(param1);
         this.listener.guiSagaSelector_select(_loc2_);
      }
      
      private function _extract_id_from_button(param1:ButtonWithIndex) : String
      {
         var _loc5_:String = null;
         var _loc2_:String = param1.name;
         var _loc3_:String = "_select_";
         var _loc4_:int = _loc2_.indexOf(_loc3_);
         if(_loc4_ >= 0)
         {
            return _loc2_.substring(_loc4_ + _loc3_.length);
         }
         return null;
      }
      
      public function performButtonPress(param1:int) : void
      {
         this.buttons[param1].press();
      }
   }
}
