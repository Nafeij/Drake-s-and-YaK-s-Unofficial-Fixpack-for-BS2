package engine.saga
{
   public class VideoParams
   {
       
      
      public var url:String;
      
      public var vo:String;
      
      public var music:String;
      
      public var subtitle:String;
      
      public var supertitle:String;
      
      public var startkillmusic:Boolean;
      
      public var noskip:Boolean;
      
      public function VideoParams()
      {
         super();
      }
      
      public function setUrl(param1:String) : VideoParams
      {
         this.url = param1;
         return this;
      }
      
      public function setSubtitle(param1:String) : VideoParams
      {
         this.subtitle = param1;
         return this;
      }
   }
}
