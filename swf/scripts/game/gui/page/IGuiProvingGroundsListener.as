package game.gui.page
{
   import engine.entity.def.IEntityDef;
   
   public interface IGuiProvingGroundsListener
   {
       
      
      function guiProvingGroundsExit() : void;
      
      function guiProvingGroundsReady() : void;
      
      function guiProvingGroundsDisplayCharacterDetails(param1:IEntityDef) : void;
      
      function guiProvingGroundsDisplayPromotion(param1:IEntityDef) : void;
      
      function guiProvingGroundsHandlePromotion(param1:IEntityDef) : void;
      
      function guiProvingGroundsCloseQuestionPages() : void;
      
      function guiProvingGroundsQuestionClick() : void;
      
      function guiProvingGroundsNamingAccept() : void;
      
      function guiProvingGroundsNamingMode() : void;
      
      function guiProvingGroundsVariationOpened() : void;
      
      function guiProvingGroundsVariationSelected() : void;
   }
}
