#ifndef FILEHELPERS_H
#define FILEHELPERS_H
#include <QString>
#include <functional>

template <class T>
class A {
private:
  T* p;
  //  typedef typename T::iterator IterT; does not compile
  typedef decltype(p->begin()) IterT;
  typedef decltype(*p->begin()) ValT;
  IterT m_iterLast;
  IterT m_iterEnd;

public:
  class B {
    int m_index;
    IterT m_iter;
    IterT m_iterLast;
    IterT m_iterEnd;

  public:
    B(IterT b, IterT c) : m_iter(b) {
      m_index = 0;
      m_iterLast = c;
      ++c;
      m_iterEnd = c;
    }

    B& operator*() {
      // std::cout << "*";
      return *this;
    }

    bool operator!=(const B& r) const {
      // std::cout << "!=";
      return m_iter != r.iter();
    }
    B& operator++() {
      // std::cout << "++";
      ++m_index;
      ++m_iter;
      return *this;
    }
    B& operator--() {
      // std::cout << "--";
      --m_index;
      --m_iter;
      return *this;
    }
    IterT& iter() { return m_iter; }
    const IterT& iter() const { return m_iter; }
    typename T::iterator& iterLast() const { return m_iterLast; }
    ValT& val() { return *m_iter; }

    auto& key() { return m_iter.key(); }
    int index() { return m_index; }
    bool isLast() { return m_iterLast == m_iter; }

  private:
  };

  A(T* _p) : p(_p) {
    auto oI = p->end();
    m_iterEnd = oI;
    if (oI != p->begin())
      --oI;
    m_iterLast = oI;
  }

  A(T* _p, int fromend) : p(_p) {
    auto oI = p->end();
    for (int i = 0; i <= fromend; ++i)
      --oI;
    m_iterLast = oI;
    ++oI;
    m_iterEnd = oI;
  }

  A(T* _p, typename T::iterator iterLast) : p(_p) {
    m_iterLast = iterLast;
    ++iterLast;
    m_iterEnd = iterLast;
  }

  B begin() {
    p->begin();
    B o(p->begin(), m_iterLast);
    return o;
  }

  B end() { return B(m_iterEnd, m_iterLast); }

  auto& last() { return *(m_iterEnd); }
};

template <class T>
class ARev {
  T* p;
  typedef decltype(p->begin()) IterT;
  typedef decltype(*p->begin()) ValT;

public:
  class B : public IterT {
  public:
    B(IterT b, T* _p) : ARev::IterT(b) {
      p = _p;
      m_index = _p->size() - 1;
    }
    B& operator*() { return *this; }
    B& operator++() {
      if (*this == p->begin()) {
        IterT::operator=(p->end());
        return *this;
      }
      --m_index;
      IterT::operator--();
      return *this;
    }

    IterT& iter() { return *this; }

    ValT& val() { return *iter(); }
    int index() { return m_index; }

  private:
    int m_index;
    T* p;
  };

  ARev(T* _p) : p(_p) {}

  B begin() {
    auto oI = p->end();
    --oI;
    return B(oI, p);
  }

  B end() {
    auto oI = p->end();
    --oI;
    return B(p->end(), p);
  }

  typename T::iterator endi() { return p->begin(); }
};

template <class T>
A<T> IterRange(T& pOc) {
  return A<T>(&pOc);
}

template <class T>
A<T> IterRange(T& pOc, int endoffset) {
  return A<T>(&pOc, endoffset);
}
template <class T>
A<T> IterRangeI(T& pOc, typename T::iterator iterEnd) {
  return A<T>(&pOc, iterEnd);
}

template <class T>
ARev<T> IterRangeRev(T& pOc) {
  return ARev<T>(&pOc);
}

QString operator^(const QString& s, const QString& s2);
class QElapsedTimer;
class StopWatch {
public:
  // Use %1 for time
  StopWatch(const QString& sMsg);
  StopWatch();
  ~StopWatch();
  void Pause();
  void Continue();
  void Stop();
  double StopTimeSec();

private:
  bool m_bMsgPrinted = false;
  QString m_sMsg;
  QElapsedTimer* m_oTimer;
};

QString JustFileNameNoExt(const QString& sFileName);
#endif  // FILEHELPERS_H
