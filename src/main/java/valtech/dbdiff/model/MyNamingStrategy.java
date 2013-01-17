package valtech.dbdiff.model;

import org.hibernate.cfg.ImprovedNamingStrategy;
import org.hibernate.cfg.NamingStrategy;

public class MyNamingStrategy extends ImprovedNamingStrategy {

	private static final long serialVersionUID = -4256820554639713413L;
	public static final NamingStrategy INSTANCE = new MyNamingStrategy();

	@Override
	public String foreignKeyColumnName(String propertyName,String propertyEntityName,String propertyTableName,String referencedColumnName) {
		return super.foreignKeyColumnName(propertyName, propertyEntityName, propertyTableName, referencedColumnName) + "_id";
	}

}
