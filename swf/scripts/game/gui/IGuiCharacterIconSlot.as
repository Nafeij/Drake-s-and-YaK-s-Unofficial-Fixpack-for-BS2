package game.gui
{
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   
   public interface IGuiCharacterIconSlot extends IGuiIconSlot
   {
       
      
      function setCharacter(param1:IEntityDef, param2:EntityIconType) : void;
      
      function get character() : IEntityDef;
      
      function updatePowerText() : void;
      
      function set context(param1:IGuiContext) : void;
   }
}
