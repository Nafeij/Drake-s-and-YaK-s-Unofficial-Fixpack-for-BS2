package game.gui.page
{
   import engine.entity.def.IEntityDef;
   
   public interface IGuiMeadHouseListener
   {
       
      
      function guiMeadHouseExit() : void;
      
      function guiGoToProvingGrounds() : void;
      
      function guiMeadHouseHired(param1:IEntityDef) : void;
   }
}
