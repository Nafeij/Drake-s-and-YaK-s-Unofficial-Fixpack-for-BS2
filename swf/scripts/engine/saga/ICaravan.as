package engine.saga
{
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ILegend;
   import engine.entity.def.IPartyDef;
   import engine.saga.vars.IVariableBag;
   
   public interface ICaravan
   {
       
      
      function get vars() : IVariableBag;
      
      function get saga() : ISaga;
      
      function get roster() : IEntityListDef;
      
      function get legend() : ILegend;
      
      function get party() : IPartyDef;
   }
}
