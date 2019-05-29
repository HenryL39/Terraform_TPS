package com.wunderit.projetcd;

import static org.junit.Assert.assertEquals;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
public class MyMathTest {

    MyMath myMath = new MyMath();
    @Test
    public void sum_with3numbers() {
        System.out.println("Test1");

        assertEquals(6, myMath.sum(new int[] {1, 2, 4}));
    }
    @Test
    public void sum_with1number() {
        System.out.println("Test2");
        assertEquals(3, myMath.sum(new int[] {
                3
        }));
    }
}
