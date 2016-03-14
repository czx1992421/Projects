package com.prediction.RecommendApp;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.apache.mahout.cf.taste.common.TasteException;
import org.apache.mahout.cf.taste.impl.model.file.FileDataModel;
import org.apache.mahout.cf.taste.impl.recommender.svd.ALSWRFactorizer;
import org.apache.mahout.cf.taste.impl.recommender.svd.SVDRecommender;
import org.apache.mahout.cf.taste.model.DataModel;
import org.apache.mahout.cf.taste.recommender.RecommendedItem;

public class SVD_recommender 
{
	public static void main( String[] args ) throws IOException, TasteException
    {
    	DataModel model = new FileDataModel(new File("data/ydata-ymusic-rating-study-v1_0-train.txt"));
        SVDRecommender recommender = new SVDRecommender(model, new ALSWRFactorizer(model, 10, 0.05, 10));
    	int userID=2;
    	int itemNum=3;
    	List<RecommendedItem> recommendations = recommender.recommend(userID, itemNum);
    	System.out.println("SVD Recommender");
    	System.out.println("For user "+userID+", recommend "+itemNum+" items:");
    	for (RecommendedItem recommendation : recommendations) {
    	  System.out.println(recommendation);
    	}
    }
}
