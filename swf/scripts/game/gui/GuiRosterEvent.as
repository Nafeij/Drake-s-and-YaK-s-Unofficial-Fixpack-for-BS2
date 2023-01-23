package game.gui
{
   import engine.entity.def.IEntityDef;
   import flash.events.Event;
   
   public class GuiRosterEvent extends Event
   {
      
      public static const DISPLAY_CHARACTER_DETAILS:String = "GuiRosterEvent.DISPLAY_CHARACTER_DETAILS";
      
      public static const READY:String = "GuiRosterEvent.READY";
       
      
      private var _selectedCharacter:IEntityDef;
      
      public var slot:GuiIconSlot;
      
      public function GuiRosterEvent(param1:String, param2:IEntityDef, param3:GuiIconSlot)
      {
         this._selectedCharacter = param2;
         this.slot = param3;
         super(param1);
      }
      
      public function get selectedCharacter() : IEntityDef
      {
         return this._selectedCharacter;
      }
   }
}
