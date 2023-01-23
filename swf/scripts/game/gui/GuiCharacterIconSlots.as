package game.gui
{
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   
   public class GuiCharacterIconSlots extends GuiIconSlots implements IGuiCharacterIconSlots
   {
       
      
      protected const distanceBetweenSlots:Number = 183.8;
      
      protected var collapsed:Boolean = false;
      
      public function GuiCharacterIconSlots()
      {
         super();
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      public function getGuiCharacterIconSlot(param1:int) : IGuiCharacterIconSlot
      {
         return getIconSlot(param1) as IGuiCharacterIconSlot;
      }
      
      public function getGuiCharacterIconSlotIndex(param1:IGuiCharacterIconSlot) : int
      {
         return iconSlots.indexOf(param1 as IGuiIconSlot);
      }
      
      public function hasGuiCharacterIconSlot(param1:IGuiIconSlot) : Boolean
      {
         return hasIconSlot(param1);
      }
      
      public function clearAllGuiCharacterIconSlots() : void
      {
         clearAllIconSlots();
      }
      
      public function collapse() : void
      {
         var _loc3_:DisplayObject = null;
         var _loc1_:int = iconSlots.length * 0.5;
         var _loc2_:DisplayObject = iconSlots[_loc1_] as DisplayObject;
         for each(_loc3_ in iconSlots)
         {
            if(_loc3_ != iconSlots[_loc1_])
            {
               TweenMax.to(_loc3_,0,{"x":_loc2_.x});
            }
         }
         this.collapsed = true;
      }
      
      public function expand(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:DisplayObject = null;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         if(this.collapsed)
         {
            _loc2_ = iconSlots.length * 0.5;
            _loc3_ = iconSlots[_loc2_] as DisplayObject;
            _loc4_ = 0;
            while(_loc4_ < iconSlots.length)
            {
               if(iconSlots[_loc4_] != iconSlots[_loc2_])
               {
                  _loc5_ = this.distanceBetweenSlots * (_loc2_ - _loc4_);
                  TweenMax.to(iconSlots[_loc4_],param1,{"x":_loc3_.x - _loc5_});
               }
               _loc4_++;
            }
            this.collapsed = false;
         }
      }
   }
}
