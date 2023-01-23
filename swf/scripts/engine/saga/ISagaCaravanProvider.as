package engine.saga
{
   public interface ISagaCaravanProvider
   {
       
      
      function getCaravan(param1:String) : ICaravan;
      
      function get currentICaravan() : ICaravan;
   }
}
