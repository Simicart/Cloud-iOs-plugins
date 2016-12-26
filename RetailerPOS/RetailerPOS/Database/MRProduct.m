//
//  MRProduct.m
//  RetailerPOS
//
//  Created by mac on 4/13/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "MRProduct.h"

@implementation MRProduct

@dynamic product_id;
@dynamic sku;
@dynamic name;
@dynamic image;
@dynamic has_option;
@dynamic data_index;
@dynamic detail;
@synthesize sort_index;
@synthesize  cat_ids;

+(void)syncData:(NSDictionary *)products{
    
    //Delete data
    [MRProduct MR_truncateAll];
    
    int sortIndex =0;
    
    for(NSString * key in products.allKeys){
        if([[products objectForKey:key] isKindOfClass:[NSDictionary class]]){
            NSDictionary * product =[products objectForKey:key];
            
            NSString * sku =[NSString stringWithFormat:@"%@",[product objectForKey:@"sku"]];
            NSString * name =[NSString stringWithFormat:@"%@",[product objectForKey:@"name"]];
            NSString * image =[NSString stringWithFormat:@"%@",[product objectForKey:@"image"]];
            NSString * has_options =[NSString stringWithFormat:@"%@",[product objectForKey:@"has_options"]];
            NSString * data_index =[NSString stringWithFormat:@"%@",[product objectForKey:@"data_index"]];
            
            
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[product objectForKey:@"detail"] options:NSJSONWritingPrettyPrinted error:nil];
            NSString *detail = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            MRProduct * mrProduct =[MRProduct MR_createEntity];
            mrProduct.product_id =key;
            mrProduct.sku=sku;
            mrProduct.name=name;
            mrProduct.image=image;
            mrProduct.has_option=has_options;
            mrProduct.data_index=data_index;
            mrProduct.detail=detail;
            
            NSArray * cat_ids = [product objectForKey:@"cat_ids"] ;
            NSString * cat_ids_combile =@"";
            
            if(cat_ids && cat_ids.count >0){
                for(NSString *item in cat_ids){
                    cat_ids_combile =[cat_ids_combile stringByAppendingString:[NSString stringWithFormat:@"%@,",item]];
                }
                
                //remove , in last string
                cat_ids_combile =[cat_ids_combile substringToIndex:cat_ids_combile.length-1];
                mrProduct.cat_ids=cat_ids_combile;
            }
            
             sortIndex = sortIndex + 1;
             mrProduct.sort_index=[NSString stringWithFormat:@"%d",sortIndex];
        }
    }
    
    SAVE_DATABASE ;
}

-(Product *)convertModelProduct{
    Product * product =[Product new];
    
    [product setObject:self.sku forKey:@"sku"];
    [product setObject:self.name forKey:@"name"];
    [product setObject:self.has_option forKey:@"has_options"];
    [product setObject:self.image forKey:@"image"];

    NSDictionary *detailInfo = [NSJSONSerialization JSONObjectWithData:[self.detail dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:nil];
    
    if([detailInfo objectForKey:@"options"]){
      [product setObject:[detailInfo objectForKey:@"options"] forKey:@"options"];
    }
    
    if([detailInfo objectForKey:@"id"]){
      [product setObject:[detailInfo objectForKey:@"id"] forKey:@"id"];
    }
    
    if([detailInfo objectForKey:@"images"]){
     [product setObject:[detailInfo objectForKey:@"images"] forKey:@"images"];
    }
    
    if([detailInfo objectForKey:@"additional"]){
     [product setObject:[detailInfo objectForKey:@"additional"] forKey:@"additional"];
    }
    
    if([detailInfo objectForKey:@"is_salable"]){
     [product setObject:[detailInfo objectForKey:@"is_salable"] forKey:@"is_salable"];
    }
    
    if([detailInfo objectForKey:@"qty"]){
      [product setObject:[detailInfo objectForKey:@"qty"] forKey:@"qty"];
    }
    
    if([detailInfo objectForKey:@"is_available"]){
      [product setObject:[detailInfo objectForKey:@"is_available"] forKey:@"is_available"];
    }
    
    if([detailInfo objectForKey:@"short_description"]){
      [product setObject:[detailInfo objectForKey:@"short_description"] forKey:@"short_description"];
    }
    
    if([detailInfo objectForKey:@"description"]){
       [product setObject:[detailInfo objectForKey:@"description"] forKey:@"description"];
    }
   
    if([detailInfo objectForKey:@"price"]){
      [product setObject:[detailInfo objectForKey:@"price"] forKey:@"price"];
    }
    
    if([detailInfo objectForKey:@"final_price"]){
      [product setObject:[detailInfo objectForKey:@"final_price"] forKey:@"final_price"];
    }
    
    return product;
}



-(NSString *)getPrice{
    
    NSDictionary *detailInfo = [NSJSONSerialization JSONObjectWithData:[self.detail dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
    
    if(detailInfo && [detailInfo objectForKey:@"price"]){
      return   [NSString stringWithFormat:@"%@",[detailInfo objectForKey:@"price"]];
    }
    
    return @"0";
}

























@end
