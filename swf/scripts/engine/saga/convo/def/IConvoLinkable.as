package engine.saga.convo.def
{
   public interface IConvoLinkable
   {
       
      
      function createLink(param1:String) : void;
      
      function getLink() : ConvoLinkDef;
   }
}
