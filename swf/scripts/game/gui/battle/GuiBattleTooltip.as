package game.gui.battle
{
   import engine.gui.IEngineGuiContext;
   import engine.gui.IGuiBattleTooltip;
   import game.gui.GuiBase;
   import game.gui.GuiToolTip;
   import game.gui.IGuiContext;
   
   public class GuiBattleTooltip extends GuiBase implements IGuiBattleTooltip
   {
       
      
      private var _tooltips:Vector.<GuiToolTip>;
      
      public function GuiBattleTooltip()
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:GuiToolTip = null;
         this._tooltips = new Vector.<GuiToolTip>();
         super();
         name = "battle_tooltip";
         _loc1_ = 0;
         while(_loc1_ < 10)
         {
            _loc2_ = "tip" + _loc1_;
            _loc3_ = getChildByName(_loc2_) as GuiToolTip;
            if(!_loc3_)
            {
               break;
            }
            _loc3_.visible = false;
            this._tooltips.push(_loc3_);
            _loc1_++;
         }
         this.visible = false;
         this.mouseEnabled = this.mouseChildren = false;
      }
      
      public function init(param1:IEngineGuiContext) : void
      {
         var _loc2_:GuiToolTip = null;
         super.initGuiBase(param1 as IGuiContext);
         for each(_loc2_ in this._tooltips)
         {
            if(_loc2_)
            {
               _loc2_.init(param1 as IGuiContext);
            }
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiToolTip = null;
         for each(_loc1_ in this._tooltips)
         {
            if(_loc1_)
            {
               _loc1_.cleanup();
            }
         }
         super.cleanupGuiBase();
      }
      
      public function setTooltipStrings(param1:Array) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         if(param1)
         {
            for each(_loc3_ in param1)
            {
               if(_loc3_)
               {
                  this.setTooltipString(_loc2_,_loc3_);
                  _loc2_++;
                  if(_loc2_ >= this._tooltips.length)
                  {
                     break;
                  }
               }
            }
         }
         while(_loc2_ < this._tooltips.length)
         {
            this.setTooltipString(_loc2_,null);
            _loc2_++;
         }
         this.visible = Boolean(param1) && Boolean(param1.length);
      }
      
      private function setTooltipString(param1:int, param2:String) : void
      {
         var _loc3_:GuiToolTip = null;
         _loc3_ = this._tooltips[param1];
         if(param2)
         {
            _loc3_.visible = true;
            _loc3_.setContent(null,param2);
            _loc3_.x = -_loc3_.width / 2;
         }
         else
         {
            _loc3_.visible = false;
         }
      }
   }
}
