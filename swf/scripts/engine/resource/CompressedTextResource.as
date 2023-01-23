package engine.resource
{
   import flash.utils.ByteArray;
   
   public class CompressedTextResource extends URLBinaryResource
   {
       
      
      public var text:String;
      
      public function CompressedTextResource(param1:String, param2:ResourceManager, param3:ILoaderFactory)
      {
         super(param1,param2,param3);
      }
      
      override protected function internalOnLoadedAllComplete() : void
      {
         var _loc1_:ByteArray = data as ByteArray;
         this.text = _loc1_.readUTFBytes(_loc1_.bytesAvailable);
         _loc1_.clear();
         releaseLoader();
      }
      
      override public function get canUnloadResource() : Boolean
      {
         return true;
      }
      
      override protected function internalUnload() : void
      {
         this.text = null;
      }
   }
}
