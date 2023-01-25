package game.gui
{
   import engine.entity.def.EntityIconType;
   import engine.gui.GuiUtil;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   
   public class GuiIconSlots extends MovieClip implements IGuiIconSlots
   {
       
      
      public var iconSlots:Vector.<IGuiIconSlot>;
      
      private var _statsTooltips:Boolean = false;
      
      public function GuiIconSlots()
      {
         this.iconSlots = new Vector.<IGuiIconSlot>();
         super();
         GuiUtil.attemptStopAllMovieClips(this);
      }
      
      public function init(param1:IGuiContext) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:IGuiIconSlot = null;
         var _loc2_:int = 0;
         while(_loc2_ < numChildren)
         {
            _loc3_ = getChildAt(_loc2_);
            _loc4_ = _loc3_ as IGuiIconSlot;
            if(_loc4_)
            {
               _loc4_.init(param1);
               _loc4_.showStatsTooltip = this.statsTooltips;
               this.iconSlots.push(_loc4_);
            }
            _loc2_++;
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:IGuiIconSlot = null;
         for each(_loc1_ in this.iconSlots)
         {
            _loc1_.cleanup();
         }
         this.iconSlots = null;
      }
      
      public function get numSlots() : int
      {
         return !!this.iconSlots ? int(this.iconSlots.length) : 0;
      }
      
      public function getIconSlot(param1:int) : IGuiIconSlot
      {
         if(param1 < 0 || param1 >= this.iconSlots.length)
         {
            return null;
         }
         return this.iconSlots[param1];
      }
      
      public function hasIconSlot(param1:IGuiIconSlot) : Boolean
      {
         return this.iconSlots.indexOf(param1) >= 0;
      }
      
      public function addIconEventListener(param1:String, param2:Function) : void
      {
         var _loc3_:IGuiIconSlot = null;
         var _loc4_:EventDispatcher = null;
         for each(_loc3_ in this.iconSlots)
         {
            _loc4_ = _loc3_ as EventDispatcher;
            if(_loc4_)
            {
               _loc4_.addEventListener(param1,param2);
            }
         }
      }
      
      public function removeIconEventListener(param1:String, param2:Function) : void
      {
         var _loc3_:IGuiIconSlot = null;
         var _loc4_:EventDispatcher = null;
         for each(_loc3_ in this.iconSlots)
         {
            _loc4_ = _loc3_ as EventDispatcher;
            if(_loc4_)
            {
               _loc4_.removeEventListener(param1,param2);
            }
         }
      }
      
      public function clearAllIconSlots() : void
      {
         var _loc1_:IGuiIconSlot = null;
         var _loc2_:GuiCharacterIconSlot = null;
         for each(_loc1_ in this.iconSlots)
         {
            _loc2_ = _loc1_ as GuiCharacterIconSlot;
            if(Boolean(_loc2_) && Boolean(_loc2_.context))
            {
               _loc2_.setCharacter(null,EntityIconType.ROSTER);
            }
         }
      }
      
      public function handleLocaleChange() : void
      {
         var _loc1_:IGuiIconSlot = null;
         for each(_loc1_ in this.iconSlots)
         {
            _loc1_.handleLocaleChange();
         }
      }
      
      public function get statsTooltips() : Boolean
      {
         return this._statsTooltips;
      }
      
      public function set statsTooltips(param1:Boolean) : void
      {
         if(param1 == this._statsTooltips)
         {
            return;
         }
         this._statsTooltips = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this.iconSlots.length)
         {
            this.iconSlots[_loc2_].showStatsTooltip = this._statsTooltips;
            _loc2_++;
         }
      }
   }
}
