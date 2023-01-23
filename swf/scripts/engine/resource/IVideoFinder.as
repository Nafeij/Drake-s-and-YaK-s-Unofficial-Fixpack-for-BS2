package engine.resource
{
   public interface IVideoFinder
   {
       
      
      function getVideoUrl(param1:String) : String;
      
      function releaseVideoUrl(param1:String) : void;
   }
}
