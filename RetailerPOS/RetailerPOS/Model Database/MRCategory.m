//
//  MRCategory.m
//  RetailerPOS
//
//  Created by mac on 4/21/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "MRCategory.h"

@implementation MRCategory

@dynamic category_id;
@dynamic name;
@dynamic level;
@dynamic is_parrent;
@dynamic parrent_id;
@dynamic order_index;

+(void)syncData:(NSDictionary *)categories{
    

    
    if(categories && categories.allKeys.count >0){
        //Delete data
        [MRCategory MR_truncateAll];
        
        int orderIndex = 0;
        
        for(NSString * key in categories.allKeys){
            
            //Case SubCategory
            if([[categories objectForKey:key] isKindOfClass:[NSDictionary class]]){
                
                //Category level 2
                NSDictionary * categoryLevel2 =[categories objectForKey:key];
                DLog(@"categoryLevel2:%@",categoryLevel2);
                
                if(categoryLevel2){
                    
                    //Luu category Cha
                    MRCategory * mrCategoryParrent =[MRCategory MR_createEntity];
                    mrCategoryParrent.category_id =key;
                    mrCategoryParrent.level =[NSString stringWithFormat:@"%@",[categoryLevel2 objectForKey:@"level"]];
                    mrCategoryParrent.name =[NSString stringWithFormat:@"%@",[categoryLevel2 objectForKey:@"name"]];
                    
                    mrCategoryParrent.is_parrent =@"yes";
                    mrCategoryParrent.parrent_id =key;
                    
                    orderIndex =orderIndex + 1;
                    mrCategoryParrent.order_index = [NSNumber numberWithInt: orderIndex];
                    
                    //Category level 3
                    for(NSString * subKey in categoryLevel2){
                        if([[categoryLevel2 objectForKey:subKey] isKindOfClass:[NSDictionary class]]){
                            NSDictionary * categoryLevel3 = [categoryLevel2 objectForKey:subKey];
                            DLog(@"categoryLevel3:%@",categoryLevel3);
                            
                            MRCategory * mrCategory =[MRCategory MR_createEntity];
                            mrCategory.category_id =subKey;
                            mrCategory.level =[NSString stringWithFormat:@"%@",[categoryLevel3 objectForKey:@"level"]];
                            mrCategory.name =[NSString stringWithFormat:@"%@",[categoryLevel3 objectForKey:@"name"]];
                            
                            mrCategory.is_parrent =@"0";
                            mrCategory.parrent_id =key;
                            
                            orderIndex =orderIndex + 1;
                            mrCategory.order_index = [NSNumber numberWithInt: orderIndex];
                        }
                    }

                }
            }
        }
        
        SAVE_DATABASE ;
    }
}

@end

/*

{
    4 =     {
        10 =         {
            level = 3;
            name = "New Arrivals";
        };
        11 =         {
            level = 3;
            name = "Tops & Blouses";
        };
        12 =         {
            level = 3;
            name = "Pants & Denim";
        };
        13 =         {
            level = 3;
            name = "Dresses & Skirts";
        };
        level = 2;
        name = Women;
    };
    5 =     {
        14 =         {
            level = 3;
            name = "New Arrivals";
        };
        15 =         {
            level = 3;
            name = Shirts;
        };
        16 =         {
            level = 3;
            name = "Tees, Knits and Polos";
        };
        17 =         {
            level = 3;
            name = "Pants & Denim";
        };
        40 =         {
            level = 3;
            name = Blazers;
        };
        level = 2;
        name = Men;
    };
    6 =     {
        18 =         {
            level = 3;
            name = Eyewear;
        };
        19 =         {
            level = 3;
            name = Jewelry;
        };
        20 =         {
            level = 3;
            name = Shoes;
        };
        21 =         {
            level = 3;
            name = "Bags & Luggage";
        };
        level = 2;
        name = Accessories;
    };
    7 =     {
        22 =         {
            level = 3;
            name = "Books & Music";
        };
        23 =         {
            level = 3;
            name = "Bed & Bath";
        };
        24 =         {
            level = 3;
            name = Electronics;
        };
        25 =         {
            level = 3;
            name = "Decorative Accents";
        };
        level = 2;
        name = "Home & Decor";
    };
    8 =     {
        26 =         {
            level = 3;
            name = Women;
        };
        27 =         {
            level = 3;
            name = Men;
        };
        28 =         {
            level = 3;
            name = Accessories;
        };
        29 =         {
            level = 3;
            name = "Home & Decor";
        };
        level = 2;
        name = Sale;
    };
    9 =     {
        level = 2;
        name = VIP;
    };
    level = 1;
    name = "Default Category";
    root = 2;
}


 */