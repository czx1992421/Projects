package com.prediction.RecommendApp;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.apache.mahout.cf.taste.common.TasteException;
import org.apache.mahout.cf.taste.impl.model.file.FileDataModel;
import org.apache.mahout.cf.taste.impl.recommender.GenericItemBasedRecommender;
import org.apache.mahout.cf.taste.impl.similarity.PearsonCorrelationSimilarity;
import org.apache.mahout.cf.taste.model.DataModel;
import org.apache.mahout.cf.taste.recommender.ItemBasedRecommender;
import org.apache.mahout.cf.taste.recommender.RecommendedItem;
import org.apache.mahout.cf.taste.similarity.ItemSimilarity;

public class Item_based_recommender 
{
    public static void main( String[] args ) throws IOException, TasteException
    {
    	DataModel model = new FileDataModel(new File("data/ydata-ymusic-rating-study-v1_0-train.txt"));
    	ItemSimilarity similarity = new PearsonCorrelationSimilarity(model);
    	ItemBasedRecommender recommender = new GenericItemBasedRecommender(model, similarity);
    	int userID=2;
    	int itemNum=3;
    	List<RecommendedItem> recommendations = recommender.recommend(userID, itemNum);
    	System.out.println("Item-based Recommender");
    	System.out.println("For user "+userID+", recommend "+itemNum+" items:");
    	for (RecommendedItem recommendation : recommendations) {
    	  System.out.println(recommendation);
    	}
    }
}
