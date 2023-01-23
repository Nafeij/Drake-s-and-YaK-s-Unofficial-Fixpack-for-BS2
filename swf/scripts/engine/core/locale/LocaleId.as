package engine.core.locale
{
   public class LocaleId
   {
      
      public static const en:LocaleId = new LocaleId("en");
       
      
      public var _id:String;
      
      private var url_replace_src:String = "/locale/en/";
      
      private var url_replace_dst:String;
      
      public function LocaleId(param1:String)
      {
         super();
         if(!param1)
         {
            throw new ArgumentError("Need an id for a locale");
         }
         this._id = param1;
         if(this._id != "en")
         {
            this.url_replace_dst = "/locale/" + this._id + "/";
         }
      }
      
      public function get isEn() : Boolean
      {
         return this._id == en._id;
      }
      
      public function toString() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         if(param1 != this._id)
         {
            this._id = param1;
            this.url_replace_dst = "/locale/" + param1 + "/";
         }
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function translateLocaleUrl(param1:String) : String
      {
         if(!param1)
         {
            return null;
         }
         if(!this.url_replace_dst)
         {
            return param1;
         }
         return param1.replace(this.url_replace_src,this.url_replace_dst);
      }
      
      public function get urlBase() : String
      {
         if(this.url_replace_dst)
         {
            return this.url_replace_dst;
         }
         return this.url_replace_src;
      }
      
      public function reverseTranslateLocaleUrl(param1:String) : String
      {
         if(!this.url_replace_dst)
         {
            return param1;
         }
         return param1.replace(this.url_replace_dst,this.url_replace_src);
      }
   }
}
