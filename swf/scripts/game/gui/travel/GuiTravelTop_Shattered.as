package game.gui.travel
{
   import engine.core.locale.Locale;
   import engine.gui.GuiContextEvent;
   import engine.saga.SagaVar;
   import engine.saga.vars.VariableEvent;
   
   public class GuiTravelTop_Shattered extends GuiBaseTravelTop
   {
       
      
      public function GuiTravelTop_Shattered()
      {
         super();
      }
      
      override protected function handleLocaleHandler(param1:GuiContextEvent) : void
      {
         this.resizeLabels();
         if(_banner_renown)
         {
            _banner_renown.handleLocaleChange();
         }
      }
      
      protected function resizeLabels() : void
      {
         var _loc1_:Locale = _context.locale;
         _loc1_.fixTextFieldFormat(_tooltip$days);
         super.scaleTextfields();
      }
      
      override protected function sagaVarHandler(param1:VariableEvent) : void
      {
         if(!param1 || param1.value.def.name == SagaVar.VAR_DAYS_REMAINING)
         {
            if(_globalVars)
            {
               days = _globalVars.fetch(SagaVar.VAR_DAYS_REMAINING,null).asNumber;
            }
         }
      }
   }
}
